# frozen_string_literal: true

# Admin::DocumentReferencesController
module Admin
  class DocumentReferencesController < Admin::AdminController
    before_action :set_document
    before_action :set_document_reference, only: %i[show edit update destroy]

    # GET /admin/document_references or /admin/document_references.json
    def index
      @document_references = DocumentReference.all
      if params[:document_id]
        @document_references = DocumentReference.where(friendlier_id: @document.friendlier_id).order(position: :asc)
      else
        @pagy, @document_references = pagy(DocumentReference.all.order(friendlier_id: :asc, updated_at: :desc), items: 20)
      end
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
          format.html { redirect_to admin_document_document_references_path(@document), notice: "Document reference was successfully created." }
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
          format.html { redirect_to admin_document_document_reference_path(@document, @document_reference), notice: "Document reference was successfully updated." }
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
        format.html { redirect_to admin_document_document_references_path(@document), status: :see_other, notice: "Document reference was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    def destroy_all
      return if request.get?

      logger.debug("Destroy References")
      unless params.dig(:document_reference, :references, :file)
        raise ArgumentError, "File does not exist or is invalid."
      end

      respond_to do |format|
        if DocumentReference.destroy_all(params.dig(:document_reference, :references, :file))
          format.html { redirect_to admin_document_references_path, notice: "References were destroyed." }
        else
          format.html { redirect_to admin_document_references_path, notice: "References could not be destroyed." }
        end
      rescue => e
        format.html { redirect_to admin_document_references_path, notice: "References could not be destroyed. #{e}" }
      end
    end

    # GET   /documents/1/references/import
    # POST  /documents/1/references/import
    def import
      return if request.get?

      logger.debug("Import References")

      unless params.dig(:document_reference, :references, :file)
        raise ArgumentError, "File does not exist or is invalid."
      end

      if DocumentReference.import(params.dig(:document_reference, :references, :file))
        logger.debug("References were created successfully.")
        if params[:document_id]
          redirect_to admin_document_document_references_path(@document), notice: "References were created successfully."
        else
          redirect_to admin_document_references_path, notice: "References were created successfully."
        end
      else
        logger.debug("References could not be created.")
        if params[:document_id]
          redirect_to admin_document_document_references_path(@document), warning: "References could not be created."
        else
          redirect_to admin_document_references_path, warning: "References could not be created."
        end
      end
    rescue => e
      logger.debug("References could not be created. #{e}")
      if params[:document_id]
        redirect_to admin_document_document_references_path(@document), notice: "References could not be created. #{e}"
      else
        redirect_to admin_document_references_path, notice: "References could not be created. #{e}"
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
      params.require(:document_reference).permit(:friendlier_id, :reference_type_id, :url, :label, :position)
    end
  end
end
