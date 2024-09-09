class Asset < Kithe::Asset
  include AttrJson::Record::QueryScopes
  include Rails.application.routes.url_helpers

  # Default Sort Order
  default_scope { order(parent_id: :desc, created_at: :asc) }

  set_shrine_uploader(AssetUploader)

  # AttrJSON
  attr_json :thumbnail, :boolean, default: "false"
  attr_json :derivative_storage_type, :string, default: "public"
  attr_json :dct_references_uri_key, :string
  attr_json :label, :string

  DERIVATIVE_STORAGE_TYPE_LOCATIONS = {
    "public" => :kithe_derivatives
  }.freeze

  def full_file_url
    if Rails.env.development?
      "http://localhost:3000" + file.url
    else
      file.url
    end
  end

  # After Promotion Callbacks
  after_promotion :set_parent_dct_references_uri

  def set_parent_dct_references_uri
    GeoblacklightAdmin::SetParentDctReferencesUriJob.perform_later(self) if parent_id.present?
  end

  # Before Destroy Callbacks
  before_destroy :remove_parent_dct_references_uri

  def remove_parent_dct_references_uri
    GeoblacklightAdmin::RemoveParentDctReferencesUriJob.perform_later(self) if parent_id.present?
  end

  # After Save Callbacks
  after_save :reindex_parent

  def reindex_parent
    parent.save if parent.present?
  end
end

# Allow DocumentAsset to be used as a synonym for Asset
DocumentAsset = Asset
