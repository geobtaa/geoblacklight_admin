require "rake"
require "csv"

namespace :geoblacklight_admin do
  namespace :solr do
    desc "Delete orphans from Solr"
    task delete_orphans: :environment do
      deleted_orphans = GeoblacklightAdmin::SolrUtils.delete_solr_orphans(batch_size: 1000)
      puts "Deleted: #{deleted_orphans.inspect}"
    end
  end
end
