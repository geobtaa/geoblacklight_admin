# frozen_string_literal: true

# Document
class Document < Kithe::Work
  include AttrJson::Record::QueryScopes
  include ActiveModel::Validations

  delegate :viewer_protocol, to: :item_viewer
  delegate :viewer_endpoint, to: :item_viewer

  def item_viewer
    GeoblacklightAdmin::ItemViewer.new(references)
  end

  attr_accessor :skip_callbacks

  has_paper_trail ignore: [:publication_state]
  belongs_to :import, optional: true

  # Statesman
  has_many :document_transitions, foreign_key: "kithe_model_id", autosave: false, dependent: :destroy,
    inverse_of: :document

  # DocumentAccesses
  has_many :document_accesses, primary_key: "friendlier_id", foreign_key: "friendlier_id", autosave: false, dependent: :destroy,
    inverse_of: :document

  # DocumentDownloads
  has_many :document_downloads, primary_key: "friendlier_id", foreign_key: "friendlier_id", autosave: false, dependent: :destroy,
    inverse_of: :document

  # DocumentAssets
  def document_assets
    scope = Kithe::Asset
    scope = scope.where(parent_id: id)

    # scope = scope.page(params[:page]).per(20).order(created_at: :desc)
    scope.includes(:parent)
  end

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: DocumentTransition,
    initial_state: :draft
  ]

  def state_machine
    @state_machine ||= DocumentStateMachine.new(self, transition_class: DocumentTransition)
  end

  delegate :current_state, to: :state_machine

  before_save :transition_publication_state, unless: :skip_callbacks
  before_save :set_geometry

  # Indexer
  self.kithe_indexable_mapper = DocumentIndexer.new

  # Validations
  validates :title, :dct_accessRights_s, :gbl_resourceClass_sm, :geomg_id_s, presence: true

  # Test for collection and restricted
  validates :dct_format_s, presence: true, if: :a_downloadable_resource?

  # Downloadable Resouce
  def a_downloadable_resource?
    references_json.include?("downloadUrl")
  end

  validates_with Document::DateValidator
  validates_with Document::DateRangeValidator
  validates_with Document::BboxValidator
  validates_with Document::GeomValidator

  # Definte our AttrJSON attributes
  Element.all.each do |attribute|
    next if attribute.solr_field == "dct_references_s"

    if attribute.repeatable?
      attr_json attribute.solr_field.to_sym, attribute.field_type.to_sym, array: true, default: -> { [] }
    else
      attr_json attribute.solr_field.to_sym, attribute.field_type.to_sym, default: ""
    end
  end

  attr_json :dct_references_s, Document::Reference.to_type, array: true, default: -> { [] }

  # Index Transformations - *_json functions
  def references
    references = ActiveSupport::HashWithIndifferentAccess.new
    send(GeoblacklightAdmin::Schema.instance.solr_fields[:reference]).each do |ref|
      references[Document::Reference::REFERENCE_VALUES[ref.category.to_sym][:uri]] = ref.value
    end
    apply_downloads(references)
  end

  def references_json
    references.to_json
  end

  def apply_downloads(references)
    dct_downloads = references["http://schema.org/downloadUrl"]
    # Make sure downloads exist!
    if document_downloads.present?
      multiple_downloads = multiple_downloads_array
      if dct_downloads.present?
        multiple_downloads << {label: download_text(send(GeoblacklightAdmin::Schema.instance.solr_fields[:format])),
                                url: dct_downloads}
      end
      references[:"http://schema.org/downloadUrl"] = multiple_downloads
    end
    references
  end

  def multiple_downloads_array
    document_downloads.collect { |d| {label: d.label, url: d.value} }
  end

  ### From GBL
  ##
  # Looks up properly formatted names for formats
  #
  def proper_case_format(format)
    if I18n.exists?("geoblacklight.formats.#{format.to_s.parameterize(separator: "_")}")
      I18n.t("geoblacklight.formats.#{format.to_s.parameterize(separator: "_")}")
    else
      format
    end
  end

  ##
  # Wraps download text with proper_case_format
  #
  def download_text(format)
    download_format = proper_case_format(format)
    prefix = "Original "
    begin
      format = download_format
    rescue
      # Need to rescue if format doesn't exist
    end
    value = prefix + format.to_s
    value.html_safe
  end

  ##
  # GBL SolrDocument convience methods
  #
  def available?
    public? || same_institution?
  end

  def public?
    rights_field_data.present? && rights_field_data.casecmp("public").zero?
  end

  def local_restricted?
    local? && restricted?
  end

  def local?
    local = send(Settings.FIELDS.PROVIDER) || ""
    local.casecmp(Settings.INSTITUTION_LOCAL_NAME)&.zero?
  end

  def restricted?
    rights_field_data.blank? || rights_field_data.casecmp("restricted").zero?
  end

  def rights_field_data
    send(Settings.FIELDS.ACCESS_RIGHTS) || ""
  end

  def downloadable?
    (direct_download || download_types.present? || iiif_download) && available?
  end

  def direct_download
    references.download.to_hash if references.download.present?
  end

  def display_note
    send(Settings.FIELDS.DISPLAY_NOTE) || ""
  end

  def hgl_download
    references.hgl.to_hash if references.hgl.present?
  end

  def oembed
    references.oembed.endpoint if references.oembed.present?
  end

  def same_institution?
    institution = send(Settings.FIELDS.PROVIDER) || ""
    institution.casecmp(Settings.INSTITUTION.downcase).zero?
  end

  def iiif_download
    references.iiif.to_hash if references.iiif.present?
  end

  def data_dictionary_download
    references.data_dictionary.to_hash if references.data_dictionary.present?
  end

  def external_url
    references.url&.endpoint
  end

  def itemtype
    "http://schema.org/Dataset"
  end

  def geom_field
    send(Settings.FIELDS.GEOMETRY) || ""
  end

  def geometry
    # @TODO
    # @geometry ||= Geoblacklight::Geometry.new(geom_field)
  end

  def wxs_identifier
    send(Settings.FIELDS.WXS_IDENTIFIER) || ""
  end

  def file_format
    send(Settings.FIELDS.FORMAT) || ""
  end

  ##
  # Provides a convenience method to access a SolrDocument's References
  # endpoint url without having to check and see if it is available
  # :type => a string which if its a Geoblacklight::Constants::URI key
  #          will return a coresponding Geoblacklight::Reference
  def checked_endpoint(type)
    type = references.send(type)
    type.endpoint if type.present?
  end

  ### End / From GBL

  def thumbnail
    members.find { |m| m.respond_to?(:thumbnail) }
  end

  def access_json
    access = {}
    access_urls.each { |au| access[au.institution_code] = au.access_url }
    access.to_json
  end

  def created_at_dt
    created_at&.utc&.iso8601
  end

  def gbl_mdModified_dt
    updated_at&.utc&.iso8601
  end

  # Ensures a manually created "title" makes it into the attr_json "title"
  def dct_title_s
    title
  end

  def date_range_json
    date_ranges = []
    unless send(GeoblacklightAdmin::Schema.instance.solr_fields[:date_range]).all?(&:blank?)
      send(GeoblacklightAdmin::Schema.instance.solr_fields[:date_range]).each do |date_range|
        start_d, end_d = date_range.split("-")
        start_d = "*" if start_d == "YYYY" || start_d.nil?
        end_d = "*" if end_d == "YYYY" || end_d.nil?
        date_ranges << "[#{start_d} TO #{end_d}]" if start_d.present?
      end
    end
    date_ranges
  end

  def solr_year_json
    return [] if send(GeoblacklightAdmin::Schema.instance.solr_fields[:date_range]).blank?

    start_d, _end_d = send(GeoblacklightAdmin::Schema.instance.solr_fields[:date_range]).first.split("-")
    [start_d] if start_d.presence
  end
  alias_method :gbl_indexYear_im, :solr_year_json

  # Export Transformations - to_*
  def to_csv
    attributes = GeoblacklightAdmin::Schema.instance.exportable_fields
    attributes.map do |key, value|
      if value[:delimited]
        send(value[:destination])&.join("|")
      elsif value[:destination] == "dct_references_s"
        dct_references_s_to_csv(key, value[:destination])
      elsif value[:destination] == "b1g_publication_state_s"
        send(:current_state)
      else
        send(value[:destination])
      end
    end
  end

  def to_traject
    Kithe::Model.find_by_friendlier_id(friendlier_id).update_index(writer: Traject::DebugWriter.new({}))
  end

  def dct_references_s_to_csv(key, destination)
    send(destination).detect do |ref|
      ref.category == GeoblacklightAdmin::Schema.instance.dct_references_mappings[key]
    end.value
  rescue NoMethodError
    nil
  end

  def current_version
    # Will return 0 if no PaperTrail version exists yet
    versions&.last&.index || 0
  end

  # Institutional Access URLs
  def access_urls
    DocumentAccess.where(friendlier_id: friendlier_id).order(institution_code: :asc)
  end

  def derive_locn_geometry
    if send(GeoblacklightAdmin::Schema.instance.solr_fields[:geometry]).present?
      send(GeoblacklightAdmin::Schema.instance.solr_fields[:geometry])
    elsif send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).present?
      derive_polygon
    else
      ""
    end
  end

  # Convert BBOX to GEOM Polygon
  def derive_polygon
    if send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).present?
      # Guard against a whole world polygons
      if send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]) == "-180,-90,180,90"
        "ENVELOPE(-180,180,90,-90)"
      else
        # "W,S,E,N" convert to "POLYGON((W N, E N, E S, W S, W N))"
        w, s, e, n = send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).split(",")
        "POLYGON((#{w} #{n}, #{e} #{n}, #{e} #{s}, #{w} #{s}, #{w} #{n}))"
      end
    else
      ""
    end
  end

  def set_geometry
    return unless locn_geometry.blank? && self&.dcat_bbox&.present?

    self.locn_geometry = derive_polygon
  end

  # Convert GEOM for Solr Indexing
  def derive_dcat_bbox
    if send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).present?
      # "W,S,E,N" convert to "ENVELOPE(W,E,N,S)"
      w, s, e, n = send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).split(",")
      "ENVELOPE(#{w},#{e},#{n},#{s})"
    else
      ""
    end
  end

  def derive_dcat_centroid
    if send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).present?
      w, s, e, n = send(GeoblacklightAdmin::Schema.instance.solr_fields[:bounding_box]).split(",")
      "#{(n.to_f + s.to_f) / 2},#{(e.to_f + w.to_f) / 2}"
    else
      ""
    end
  end

  # Convert three char language code to proper string
  def iso_language_mapping
    mapping = []

    if send(GeoblacklightAdmin::Schema.instance.solr_fields[:language]).present?
      send(GeoblacklightAdmin::Schema.instance.solr_fields[:language]).each do |lang|
        mapping << GeoblacklightAdmin::IsoLanguageCodes.call[lang]
      end
    end
    mapping
  end

  private

  def transition_publication_state
    state_machine.transition_to!(publication_state.downcase) if publication_state_changed?
  end
end
