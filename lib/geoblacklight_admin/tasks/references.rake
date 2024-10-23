namespace :geoblacklight_admin do
  namespace :references do
    desc "Migrate references into DocumentReferences"
    task migrate: :environment do
      total_documents_processed = 0
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          # Move AttrJson dct_references_s into DocumentReferences
          document.dct_references_s.each do |reference|
            puts "Processing reference: #{reference.inspect}"

            reference_type_pk_id = ReferenceType.find_by(name: reference.category).id

            puts "Creating DocumentReference"
            puts "Friendlier ID: #{document.friendlier_id}"
            puts "Reference Type ID: #{reference_type_pk_id}"
            puts "URL: #{reference.value}"

            begin
              DocumentReference.create!(
                friendlier_id: document.friendlier_id,
                reference_type_id: reference_type_pk_id,
                url: reference.value
              )
            rescue ActiveRecord::RecordInvalid => e
              puts "Error creating DocumentReference: #{e.message}"
            end
          end

          # Migrate multiple download links into DocumentReferences
          document.document_downloads.each do |download|
            puts "Processing multiple download link: #{download.inspect}"

            begin
              DocumentReference.create!(
                friendlier_id: document.friendlier_id,
                reference_type_id: ReferenceType.find_by(name: "download").id,
                url: download.value,
                label: download.label
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

    task audit: :environment do
      # @TODO: Audit DocumentReferences to ensure they are correct
    end

    task finalize: :environment do
      # @TODO: Finalize DocumentReferences to ensure they are correct
      # Remove dct_references_s from Documents
      # Remove multiple download links from Documents
      # Remove assets from Documents
    end
  end
end
