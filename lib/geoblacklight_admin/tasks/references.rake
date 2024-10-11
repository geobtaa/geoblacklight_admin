namespace :geoblacklight_admin do
  namespace :references do
    desc "Migrate references from dct_references_s to document_references"
    task migrate: :environment do
      total_documents_processed = 0
      Document.find_in_batches(batch_size: 1000) do |documents|
        documents.each do |document|
          document.dct_references_s.each do |reference|
            puts "Processing reference: #{reference.inspect}"
            reference_type = Document::Reference.reference_values[reference.category.to_sym][:label]
            puts "Reference type: #{reference_type}"
            reference_id = Reference.find_by(name: reference.category).id
            puts "Reference id: #{reference_id}"

            DocumentReference.create!(
              friendlier_id: document.friendlier_id,
              reference_id: reference_id,
              url: reference.value
            )
          end
        end
        total_documents_processed += documents.size
        puts "Processed #{documents.size} documents in this batch, total processed: #{total_documents_processed}"
      end
    end
  end
end
