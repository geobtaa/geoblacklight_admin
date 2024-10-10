# frozen_string_literal: true

# Admin::DocumentReferencesController
module Admin
  class DocumentReferencesController < Admin::AdminController
    before_action :set_document
    before_action :set_document_reference, only: %i[show edit update destroy]

    # GET /admin/document_references or /admin/document_references.json
    def index
      @document_references = DocumentReference.all
    end

    # GET /admin/document_references/1 or /admin/document_references/1.json
    def show
    end

    # GET /admin/document_references/new
    def new
      @document_reference = DocumentReference.new
    end

    # GET /admin/document_references/1/edit
    def edit
    end

    # POST /admin/document_references or /admin/document_references.json
    def create
      @document_reference = DocumentReference.new(document_reference_params)

      respond_to do |format|
        if @document_reference.save
          format.html { redirect_to @document_reference, notice: "Document reference was successfully created." }
          format.json { render :show, status: :created, location: @document_reference }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @document_reference.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/document_references/1 or /admin/document_references/1.json
    def update
      respond_to do |format|
        if @document_reference.update(document_reference_params)
          format.html { redirect_to @document_reference, notice: "Document reference was successfully updated." }
          format.json { render :show, status: :ok, location: @document_reference }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @document_reference.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/document_references/1 or /admin/document_references/1.json
    def destroy
      @document_reference.destroy!

      respond_to do |format|
        format.html { redirect_to document_references_path, status: :see_other, notice: "Document reference was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_document
        return unless params[:document_id] # If not nested
  
        @document = Document.includes(:leaf_representative).find_by!(friendlier_id: params[:document_id])
      end

      def set_document_reference
        @document_reference = DocumentReference.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def document_reference_params
        params.fetch(:document_reference, {})
      end
  end
end
