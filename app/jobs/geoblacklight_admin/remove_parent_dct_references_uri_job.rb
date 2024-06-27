# frozen_string_literal: true

module GeoblacklightAdmin
  class RemoveParentDctReferencesUriJob < ApplicationJob
    queue_as :priority

    def perform(asset)
      if asset.dct_references_uri_key.present?
        asset.parent.dct_references_s.delete_if { |i| i.value == asset.full_file_url }
        asset.parent.save!
      end
    rescue => e
      Rails.logger.error "\nError - Removing parent dct_references URI: #{e.message} \n"
    end
  end
end
