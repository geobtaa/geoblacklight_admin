# frozen_string_literal: true

module GeoblacklightAdmin
  class StoreImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id, bad_id = nil)
      # Find the document
      document = Document.find_by_friendlier_id(solr_document_id)

      # Skip if thumbnail is already stored
      return if document&.thumbnail&.present?

      # Statesman
      metadata = {}
      metadata["solr_doc_id"] = solr_document_id
      document.thumbnail_state_machine.transition_to!(:queued, metadata)

      # Crawl politely
      sleep(rand(1..5))

      # Store the image
      GeoblacklightAdmin::ImageService.new(document).store
      BulkActionDocument.find(bad_id).state_machine.transition_to!(:success) if bad_id.present?
    end
  end
end
