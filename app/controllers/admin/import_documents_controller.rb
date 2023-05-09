# frozen_string_literal: true

# Admin::ImportDocumentsController
module Admin
  class ImportDocumentsController < Admin::AdminController
    before_action :set_import_document, only: %i[show]

    def show
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_import_document
      @import_document = ImportDocument.find(params[:id])
    end
  end
end