# frozen_string_literal: true

module GeoblacklightAdmin
  class StoreImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id, bad_id = nil)
      document = Document.find_by_friendlier_id(solr_document_id)
      GeoblacklightAdmin::ImageService.new(document).store
      BulkActionDocument.find(bad_id).state_machine.transition_to!(:success) if bad_id.present?
    end
  end
end
