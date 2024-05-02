# frozen_string_literal: true

module GeoblacklightAdmin
  class DeleteThumbnailJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id)
      document = Document.find_by_friendlier_id(solr_document_id)
      if document.thumbnail.present?
        document.thumbnail.destroy!
      end
    end
  end
end
