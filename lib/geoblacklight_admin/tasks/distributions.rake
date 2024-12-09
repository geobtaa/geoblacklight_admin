require "rake"
require "csv"

namespace :geoblacklight_admin do
  namespace :distributions do
    desc "Migrate distributions into DocumentDistributions"
    task migrate: :environment do
      total_documents_processed = 0
      puts "\n--- Migration Start ---"
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Moves AttrJson-based dct_references_s and Multiple Downloads into DocumentDistributions

          document.distributions_csv.each do |distribution|
            DocumentDistribution.find_or_create_by!(
              friendlier_id: distribution[0],
              reference_type_id: ReferenceType.find_by(name: distribution[1]).id,
              url: distribution[2],
              label: distribution[3]
            )
          end
        rescue => e
          puts "\nError processing distributions for document: #{document.friendlier_id} - #{e.inspect}\n"
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
      puts "--- Migration End ---\n"
    end

    desc "Audit the distributions migration"
    task audit: :environment do
      total_documents_processed = 0
      puts "\n--- Audit Start ---"
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Document > Distributions as CSV
          dr_csv = document.references_csv.sort

          # document_distributions
          doc_dists = document.document_distributions.collect { |dr| dr.to_csv }.sort

          if dr_csv != doc_dists
            puts "\nNO MATCH"
            puts "Document: #{document.friendlier_id}"
            puts "CSV Distributions Sorted: #{dr_csv.sort.inspect}"
            puts "Document Distributions Sorted: #{doc_dists.sort.inspect}\n"
          end
        rescue => e
          puts "\nError auditing distributions for document: #{document.friendlier_id} - #{e.inspect}\n"
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
      puts "--- Audit End ---\n"
    end

    task finalize: :environment do
      # Step 1 - After migrate, flip the ENV var feature flag
      # Done: Remove multiple download links from Documents
      # Done: Remove multiple download links from FormElements (it's a feature there)
      # Done: Remove multiple download links from FormNav (link)
      # Done: Add DocumentDistributions to the FormElements (as a feature - manual)

      # Step 2 - Finalize
      # Remove AttrJson dct_references_s values from Documents (data is redundant and/or incorrect)
    end
  end
end
