# frozen_string_literal: true

module GeoblacklightAdmin
  class StoreImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id, bad_id = nil)
      # Find the document
      document = Document.find_by_friendlier_id(solr_document_id)

      # Crawl politely
      sleep(rand(1..5))

      # Skip if thumbnail is already stored
      return if document&.thumbnail&.present?

      # Store the image
      GeoblacklightAdmin::ImageService.new(document).store
      BulkActionDocument.find(bad_id).state_machine.transition_to!(:success) if bad_id.present?
    end
  end
end
