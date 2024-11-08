namespace :geoblacklight_admin do
  namespace :references do
    desc "Migrate references into DocumentReferences"
    task migrate: :environment do
      total_documents_processed = 0
      puts "\n--- Migration Start ---"
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Moves AttrJson-based dct_references_s and Multiple Downloads into DocumentReferences
          begin
            document.references_csv.each do |reference|      
              DocumentReference.find_or_create_by!(
                friendlier_id: reference[0],
                reference_type_id: ReferenceType.find_by(name: reference[1]).id,
                url: reference[2],
                label: reference[3]
              )
            end
          rescue => e
            puts "\nError processing references for document: #{document.friendlier_id} - #{e.inspect}\n"
          end
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
      puts "--- Migration End ---\n"
    end

    desc "Audit the references migration"
    task audit: :environment do
      total_documents_processed = 0
      puts "\n--- Audit Start ---"
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          begin
            # Document > References as CSV
            dr_csv = document.references_csv.sort
      
            # document_references
            doc_refs = document.document_references.collect { |dr| dr.to_csv }.sort
      
            if dr_csv != doc_refs
              puts "\nNO MATCH"
              puts "Document: #{document.friendlier_id}"
              puts "CSV References Sorted: #{dr_csv.sort.inspect}"
              puts "Document References Sorted: #{doc_refs.sort.inspect}\n"
            end
          rescue => e
            puts "\nError auditing references for document: #{document.friendlier_id} - #{e.inspect}\n"
          end
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
      puts "--- Audit End ---\n"
    end

    task finalize: :environment do
      # @TODO: Finalize DocumentReferences to ensure they are correct
      # Remove dct_references_s from FormElements
      # Remove AttrJson dct_references_s from Documents
      # Remove dct_references_s from Elements (maybe not?)
      # Remove multiple download links from Documents
    end
  end
end
