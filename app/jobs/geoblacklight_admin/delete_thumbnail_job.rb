# frozen_string_literal: true

module GeoblacklightAdmin
  class DeleteThumbnailJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id, bad_id = nil)
      document = Document.find_by_friendlier_id(solr_document_id)
      if document.thumbnail.present?
        document.thumbnail.destroy!
      end
      BulkActionDocument.find(bad_id).state_machine.transition_to!(:success) if bad_id.present?
    end
  end
end
