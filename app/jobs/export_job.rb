# frozen_string_literal: true

require "csv"
require "zip"

# ExportJob
class ExportJob < ApplicationJob
  queue_as :priority

  def perform(request, current_user, query_params, export_service)
    logger.debug("\n\n Background Job: ♞")
    logger.debug("Request: #{request.inspect}")
    logger.debug("User: #{current_user.inspect}")
    logger.debug("Query: #{query_params.inspect}")
    logger.debug("Export Service: #{export_service.inspect}")
    logger.debug("\n\n")

    # Test broadcast
    ActionCable.server.broadcast("export_channel", {data: "Hello from Export Job!"})

    # Query params into Doc ids
    document_ids = query_params[:ids] || crawl_query(request, query_params)

    logger.debug("Document Ids: #{document_ids}")

    # Send progress
    file_content_documents = export_service.call(document_ids)
    file_content_document_references = ExportCsvDocumentReferencesService.call(document_ids)

    # Write Documents into tempfile
    @tempfile_documents = Tempfile.new(["documents-#{Time.zone.today}", ".csv"]).tap do |file|
      CSV.open(file, "wb") do |csv|
        file_content_documents.each do |row|
          csv << row
        end
      end
      logger.debug("Tempfile Documents Path: #{file.path}")
      logger.debug("Tempfile Documents Size: #{File.size(file.path)} bytes")
    end

    # Write DocumentReferences into tempfile
    @tempfile_document_references = Tempfile.new(["document-references-#{Time.zone.today}", ".csv"]).tap do |file|
      CSV.open(file, "wb") do |csv|
        file_content_document_references.each do |row|
          csv << row
        end
      end
      logger.debug("Tempfile Document References Path: #{file.path}")
      logger.debug("Tempfile Document References Size: #{File.size(file.path)} bytes")
    end

    # Create a zip file containing both tempfiles
    zipfile_name = "export-#{Time.zone.today}.zip"
    tmp_dir = Rails.root.join("tmp")
    @tempfile_zip = Tempfile.new([zipfile_name, ".zip"], tmp_dir)

    Zip::File.open(@tempfile_zip.path, Zip::File::CREATE) do |zipfile|
      zipfile.add("documents.csv", @tempfile_documents.path)
      zipfile.add("document-references.csv", @tempfile_document_references.path)
    end
    logger.debug("Zipfile Path: #{@tempfile_zip.path}")
    logger.debug("Zipfile Size: #{File.size(@tempfile_zip.path)} bytes")

    # Create notification
    # Message: "Download Type|Row Count|Button Label"
    notification = ExportNotification.with(message: "ZIP (#{export_service.short_name})|#{ActionController::Base.helpers.number_with_delimiter(file_content_documents.size - 1)} rows|ZIP")

    # Deliver notification
    notification.deliver(current_user)

    # Attach ZIP file (can only attach after persisted)
    notification.record.file.attach(io: File.open(@tempfile_zip), filename: zipfile_name,
      content_type: "application/zip")

    # Update UI
    ActionCable.server.broadcast("export_channel", {
      data: "Notification ready!",
      actions: [
        {
          method: "RefreshNotifications",
          payload: current_user.notifications.unread.count
        }
      ]
    })
  end

  def crawl_query(request, query_params, doc_ids = [])
    logger.debug("\n\n CRAWL Query: #{query_params}")
    logger.debug("\n\n CRAWL Query Request: #{request}")
    api_results = BlacklightApiIds.new(request, query_params)
    logger.debug("API Results: #{api_results.results.inspect}")

    doc_ids << api_results.results.pluck("id")

    unless api_results.meta["pages"]["next_page"].nil?
      crawl_query(request, query_params.merge!({page: api_results.meta["pages"]["next_page"]}),
        doc_ids)
    end

    doc_ids
  end
end
