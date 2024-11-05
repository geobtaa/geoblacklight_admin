namespace :geoblacklight_admin do
  namespace :references do
    desc "Migrate references into DocumentReferences"
    task migrate: :environment do
      total_documents_processed = 0
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Move AttrJson dct_references_s into DocumentReferences
          document.references_csv.each do |reference|
            puts "Processing reference: #{reference.inspect}"

            begin
              DocumentReference.find_or_create_by!(
                friendlier_id: reference[0],
                reference_type_id: ReferenceType.find_by(name: reference[1]).id,
                url: reference[2],
                label: reference[3]
              )
            rescue ActiveRecord::RecordInvalid => e
              puts "Error creating DocumentReference: #{e.message}"
            end
          end

          # @TODO: Move Relationships into DocumentReferences
          # ex. should assets like thumbnails be included in DocumentReferences?
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
    end

    desc "Audit the references migration"
    task audit: :environment do
      total_documents_processed = 0
      puts "\n--- Audit Start ---"
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Document > References as CSV
          dr_csv = document.references_csv

          # document_references
          doc_refs = document.document_references.collect { |dr| dr.to_csv }

          if dr_csv != doc_refs
            puts "Document: #{document.friendlier_id}"
            puts "CSV References: #{dr_csv.inspect}"
            puts "Document References: #{doc_refs.inspect}"
            puts "NO MATCH"
          end
        end
        total_documents_processed += documents.size
        puts "--- Audit End ---\n"
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
    end

    task finalize: :environment do
      # @TODO: Finalize DocumentReferences to ensure they are correct
      # Remove dct_references_s from Documents
      # Remove multiple download links from Documents
      # Remove assets from Documents
    end
  end
end
