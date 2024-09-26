# frozen_string_literal: true

# ImportDocumentJob class
class ImportDocumentJob < ApplicationJob
  queue_as :priority

  def perform(import_document)
    document = Document.find_or_create_by(friendlier_id: import_document.friendlier_id)

    # Set the geom
    document.set_geometry

    if document.update(import_document.to_hash)
      import_document.state_machine.transition_to!(:success)
    else
      import_document.state_machine.transition_to!(:failed, "Failed - #{document.errors.inspect}")
    end
  rescue => e
    logger.debug("Error: #{e}")
    import_document.state_machine.transition_to!(:failed, "Error - #{e.inspect}")
  end
end
