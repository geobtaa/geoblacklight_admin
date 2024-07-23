require "json"
require "rsolr"

module GeoblacklightAdmin
  # @CUSOMIZATION
  # This is mostly a copy of the Kithe::SolrUtil module from the Kithe gem
  # with the exception changing id to geomg_id_s

  # This is all somewhat hacky code, but it gets the job done. Some convenience utilities for dealing
  # with your Solr index, including issuing a query to delete_all; and finding and deleting "orphaned"
  # Kithe::Indexable Solr objects that no longer exist in the rdbms.
  #
  # Unlike other parts of Kithe's indexing support, this stuff IS very solr-specific, and generally
  # implemented with [rsolr](https://github.com/rsolr/rsolr).
  module SolrUtils
    # based on sunspot, does not depend on Blacklight.
    # https://github.com/sunspot/sunspot/blob/3328212da79178319e98699d408f14513855d3c0/sunspot_rails/lib/sunspot/rails/searchable.rb#L332
    #
    #     solr_index_orphans do |orphaned_id|
    #        delete(id)
    #     end
    #
    # It is searching for any Solr object with a `Kithe.indexable_settings.model_name_solr_field`
    # field (default `model_name_ssi`). Then, it takes the ID and makes sure it exists in
    # the database using Kithe::Model. At the moment we are assuming everything is in Kithe::Model,
    # rather than trying to use the `model_name_ssi` to fetch from different tables. Could
    # maybe be enhanced to not.
    #
    # This is intended mostly for use by .delete_solr_orphans
    #
    # A bit hacky implementation, it might be nice to support a progress bar, we
    # don't now.
    def self.solr_orphan_geomg_ids(batch_size: 100, solr_url: Kithe.indexable_settings.solr_url)
      return enum_for(:solr_index_orphan_ids) unless block_given?

      model_solr_id_attr = Kithe.indexable_settings.solr_id_value_attribute

      solr_page = -1

      rsolr = RSolr.connect url: solr_url

      while (solr_page = solr_page.next)
        response = rsolr.get "select", params: {
          rows: batch_size,
          start: (batch_size * solr_page),
          fl: "geomg_id_s",
          q: "* TO *"
        }

        solr_geomg_ids = response["response"]["docs"].collect { |h| h["geomg_id_s"] }

        break if solr_geomg_ids.empty?

        (solr_geomg_ids - Kithe::Model.where(model_solr_id_attr => solr_geomg_ids).pluck(model_solr_id_attr)).each do |orphaned_geomg_id|
          yield orphaned_geomg_id
        end
      end
    end

    # Finds any Solr objects that have a `model_name_ssi` field
    # (or `Kithe.indexable_settings.model_name_solr_field` if non-default), but don't
    # exist in the rdbms, and deletes them from Solr, then issues a commit.
    #
    # Under normal use, you shouldn't have to do this, but can if your Solr index
    # has gotten out of sync and you don't want to delete it and reindex from
    # scratch.
    #
    # Implemented in terms of .solr_orphan_ids.
    #
    # A bit hacky implementation, it might be nice to have a progress bar, we don't now.
    #
    # Does return an array of any IDs deleted.
    def self.delete_solr_orphans(batch_size: 100, solr_url: Kithe.indexable_settings.solr_url)
      rsolr = RSolr.connect url: solr_url
      deleted_geomg_ids = []

      solr_orphan_geomg_ids(batch_size: batch_size, solr_url: solr_url) do |orphan_geomg_id|
        deleted_geomg_ids << orphan_geomg_id
        rsolr.delete_by_query("geomg_id_s:#{orphan_geomg_id}")
      end

      rsolr.commit

      deleted_geomg_ids
    end
  end
end
