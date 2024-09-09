# frozen_string_literal: true

# AssetHelper
module AssetHelper
  def asset_thumb_to_render?(asset)
    asset&.file_url&.present? && asset&.file_derivatives&.present?
  end
end
