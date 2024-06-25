# frozen_string_literal: true

module GeoblacklightAdmin
  class SetParentDctReferencesUriJob < ApplicationJob
    queue_as :priority

    def perform(asset)
      if asset.dct_references_uri_key.present?
        reference = Document::Reference.new
        reference.category = asset.dct_references_uri_key
        reference.value = asset.full_file_url
        asset.parent.dct_references_s << reference
        asset.parent.save!
      end
    rescue => e
      Rails.logger.error "\nError - Setting parent DCT references URI: #{e.message}\n"
    end
  end
end
