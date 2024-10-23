# frozen_string_literal: true

require "csv"

# ExportCsvDocumentReferencesService
#
# This service is responsible for exporting document references to a CSV format.
# It broadcasts the progress of the export process via ActionCable.
class ExportCsvDocumentReferencesService
  # Returns a short name for the service.
  #
  # @return [String] the short name of the service.
  def self.short_name
    "Document References"
  end

  # Initiates the CSV export process for the given document IDs.
  #
  # @param document_ids [Array] an array of document IDs to export.
  # @return [Array] the generated CSV file content as an array of rows.
  #
  # This method broadcasts the progress of the export process to the "export_channel".
  # It processes the document IDs in slices and handles any NoMethodError exceptions
  # that occur during the export process.
  def self.call(document_ids)
    ActionCable.server.broadcast("export_channel", {progress: 0})

    document_ids = document_ids.flatten
    total = document_ids.size
    count = 0
    slice_count = 100
    csv_file = []

    Rails.logger.debug { "\n\nExportCsvDocumentReferencesService: #{document_ids.inspect}\n\n" }

    CSV.generate(headers: true) do |_csv|
      csv_file << DocumentReference.csv_column_names
      document_ids.each_slice(slice_count) do |slice|
        # Broadcast progress percentage
        count += slice_count
        progress = ((count.to_f / total) * 100).round
        progress = 100 if progress > 100

        ActionCable.server.broadcast("export_channel", {progress: progress})
        slice.each do |doc_id|
          doc = Document.find_by(friendlier_id: doc_id)

          Rails.logger.debug { "\n\nDocReferences: #{doc.document_references.size}\n\n" }

          doc.document_references.each do |reference|
            csv_file << reference.to_csv
          end
        rescue NoMethodError
          Rails.logger.debug { "\n\nExport Failed: #{doc_id.inspect}\n\n" }
        end
      end
    end

    csv_file
  end
end
