require "csv"

namespace :geoblacklight_admin do
  namespace :images do
    desc "Harvest image for specific document"
    task harvest_doc_id: :environment do
      GeoblacklightAdmin::StoreImageJob.perform_later(ENV["DOC_ID"])
    end

    desc "Harvest all images"
    task harvest_all: :environment do
      query = "*:*"
      index = Geoblacklight::SolrDocument.index
      results = index.send_and_receive(index.blacklight_config.solr_path,
        q: query,
        fl: "*",
        rows: 100_000_000)
      # num_found = results.response[:numFound]
      # doc_counter = 0
      results.docs.each do |document|
        sleep(1)
        begin
          GeoblacklightAdmin::StoreImageJob.perform_later(document["id"])
        rescue Blacklight::Exceptions::RecordNotFound
          next
        end
      end
    end
  end
end
