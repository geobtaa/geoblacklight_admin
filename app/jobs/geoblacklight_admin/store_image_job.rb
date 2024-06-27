# frozen_string_literal: true

module GeoblacklightAdmin
  class StoreImageJob < ApplicationJob
    queue_as do
      arguments.last
    end

    def perform(solr_document_id, bad_id = nil, queue = :default)
      # Find the document
      document = Document.find_by_friendlier_id(solr_document_id)

      # Delete thumbnail if already present
      if document&.thumbnail&.present?
        document.thumbnail.destroy!
      end

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
