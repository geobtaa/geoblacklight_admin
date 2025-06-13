# frozen_string_literal: true

# ImportDocumentJob class
class ImportDocumentJob < ApplicationJob
  queue_as :priority

  def perform(import_document)
    document = Document.find_or_create_by(friendlier_id: import_document.friendlier_id)

    # Set the geom
    document.set_geometry

    # Update document with import data
    document_data = import_document.to_hash
    document_data[:publication_state] = document_data[:json_attributes]["b1g_publication_state_s"] if document_data[:json_attributes]["b1g_publication_state_s"].present?

    if document.update(document_data)
      import_document.state_machine.transition_to!(:success)
    else
      import_document.state_machine.transition_to!(:failed, "Failed - #{document.errors.inspect}")
    end
  rescue => e
    logger.debug("Error: #{e}")
    import_document.state_machine.transition_to!(:failed, "Error - #{e.inspect}")
  end
end
