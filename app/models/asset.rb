class Asset < Kithe::Asset
  include AttrJson::Record::QueryScopes
  
  set_shrine_uploader(AssetUploader)

  # AttrJSON
  attr_json :thumbnail, :boolean, default: "false"
  attr_json :derivative_storage_type, :string, default: "public"

  DERIVATIVE_STORAGE_TYPE_LOCATIONS = {
    "public" => :kithe_derivatives
  }.freeze
end