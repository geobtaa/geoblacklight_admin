# frozen_string_literal: true

module GeoblacklightAdmin
  class StoreImageJob < ApplicationJob
    queue_as :default

    def perform(solr_document_id)
      document = Document.find_by_friendlier_id(solr_document_id)
      GeoblacklightAdmin::ImageService.new(document).store
    end
  end
end
