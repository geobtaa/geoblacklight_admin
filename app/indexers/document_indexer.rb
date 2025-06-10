# frozen_string_literal: true

# Solr indexing for our document class. Still a work in progress.
#
# The DocumentIndexer class is responsible for configuring how documents
# are indexed into Solr. It uses the Kithe::Indexer framework to map
# document attributes to Solr fields.
#
# The configuration block defines various fields that are indexed, including
# fields specific to GeoBlacklight and custom fields defined via the Element model.
#
# Fields:
# - model_pk_ssi: The primary key of the model, extracted from the object's ID.
# - gbl_mdVersion_s: A static version string for GeoBlacklight.
# - gbl_mdModified_dt: The modification date of the metadata.
# - date_created_dtsi: The creation date of the record, in UTC ISO8601 format.
# - date_modified_dtsi: The last modification date of the record, in UTC ISO8601 format.
# - b1g_geom_import_id_ssi: The import ID for GeoBlacklight administration.
#
# If the "elements" table exists, additional fields are indexed based on
# the Element model's configuration.
class DocumentIndexer < Kithe::Indexer
  configure do
    # Kithe
    to_field "model_pk_ssi", obj_extract("id") # the actual db pk, a UUID

    # GeoBlacklight
    to_field "gbl_mdVersion_s", literal("Aardvark")

    # to_field 'geomg_id_s', obj_extract('friendlier_id') # the actual db pk, a UUID

    # Define `to_field`(s) via Element
    if ActiveRecord::Base.connection.table_exists?("elements")
      Element.indexable.each do |elm|
        to_field elm.solr_field, obj_extract(elm.index_value)
      end
    end

    to_field "gbl_mdModified_dt", obj_extract("gbl_mdModified_dt")

    # May want to switch to or add a 'date published' instead, right
    # now we only have date added to DB, which is what we had in sufia.
    to_field "date_created_dtsi" do |rec, _acc|
      rec&.created_at&.utc&.iso8601
    end

    to_field "date_modified_dtsi" do |rec, _acc|
      rec&.updated_at&.utc&.iso8601
    end

    # - GBL ADMIN
    to_field "b1g_geom_import_id_ssi", obj_extract("import_id")
  end
end
