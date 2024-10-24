require "rake"
require "csv"

namespace :geoblacklight_admin do
  namespace :solr do
    desc "Delete orphans from Solr"
    task delete_orphans: :environment do
      deleted_orphans = GeoblacklightAdmin::SolrUtils.delete_solr_orphans(batch_size: 1000)
      puts "Deleted: #{deleted_orphans.inspect}"
    end

    desc "Reindex all Documents"
    task reindex: :environment do
      Kithe::Indexable.index_with(batching: true) do
        progress_bar = ProgressBar.create(total: Document.count, format: Kithe::STANDARD_PROGRESS_BAR_FORMAT)

        scope = Kithe::Model.where(kithe_model_type: 1)

        scope.find_each do |model|
          progress_bar.title = "#{model.class.name}:#{model.friendlier_id}"
          model.update_index
          progress_bar.increment
        end
      end
    end
  end
end
