# frozen_string_literal: true

# Admin::DocumentAccessesController
#
# This controller manages the CRUD operations for DocumentAccess objects
# within the admin namespace. It provides actions to list, show, create,
# update, and destroy document access records. It also includes custom
# actions for importing and destroying all document access links.
#
# Actions:
# - index: Lists all document accesses, optionally filtered by document_id.
# - show: Displays a specific document access.
# - new: Renders a form for creating a new document access.
# - edit: Renders a form for editing an existing document access.
# - create: Creates a new document access.
# - update: Updates an existing document access.
# - destroy: Deletes a specific document access.
# - destroy_all: Deletes all document access links provided in the params.
# - import: Imports document access links from a file provided in the params.
#
# Before Actions:
# - set_document: Sets the @document instance variable if document_id is present.
# - set_document_access: Sets the @document_access instance variable for specific actions.
#
# Private Methods:
# - set_document: Finds and sets the document based on the document_id parameter.
# - set_document_access: Finds and sets the document access based on the id parameter.
# - document_access_params: Permits only trusted parameters for document access.
module Admin
  class DocumentAccessesController < Admin::AdminController
    before_action :set_document
    before_action :set_document_access, only: %i[show edit update destroy]

    # GET /documents/#id/access
    # GET /documents/#id/access.json
    # Lists all document accesses, optionally filtered by document_id.
    def index
      if params[:document_id]
        @document_accesses = DocumentAccess.where(friendlier_id: @document.friendlier_id).order(institution_code: :asc)
      else
        @pagy, @document_accesses = pagy(DocumentAccess.all.order(friendlier_id: :asc, updated_at: :desc), items: 20)
      end
    end

    # GET /document_accesses/1
    # GET /document_accesses/1.json
    # Displays a specific document access.
    def show
    end

    # GET /document_accesses/new
    # Renders a form for creating a new document access.
    def new
      @document_access = DocumentAccess.new
    end

    # GET /document_accesses/1/edit
    # Renders a form for editing an existing document access.
    def edit
    end

    # POST /document_accesses
    # POST /document_accesses.json
    # Creates a new document access.
    def create
      @document_access = DocumentAccess.new(document_access_params)
      logger.debug("DA Params: #{DocumentAccess.new(document_access_params).inspect}")
      logger.debug("Document ACCESS: #{@document_access.inspect}")

      respond_to do |format|
        if @document_access.save
          format.html do
            redirect_to admin_document_document_accesses_path(@document), notice: "Document access was successfully created."
          end
          format.json { render :show, status: :created, location: @document_access }
        else
          format.html { render :new }
          format.json { render json: @document_access.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /document_accesses/1
    # PATCH/PUT /document_accesses/1.json
    # Updates an existing document access.
    def update
      respond_to do |format|
        if @document_access.update(document_access_params)
          format.html do
            redirect_to admin_document_document_accesses_path(@document), notice: "Document access was successfully updated."
          end
          format.json { render :show, status: :ok, location: @document_access }
        else
          format.html { render :edit }
          format.json { render json: @document_access.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /document_accesses/1
    # DELETE /document_accesses/1.json
    # Deletes a specific document access.
    def destroy
      @document_access.destroy
      respond_to do |format|
        format.html do
          redirect_to admin_document_document_accesses_path(@document), notice: "Document access was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    # DELETE /document_accesses/destroy_all
    # Deletes all document access links provided in the params.
    def destroy_all
      logger.debug("Destroy Access Links")
      return unless params.dig(:document_access, :assets, :file)

      respond_to do |format|
        if DocumentAccess.destroy_all(params.dig(:document_access, :assets, :file))
          format.html { redirect_to admin_document_accesses_path, notice: "Document Access Links were created destroyed." }
        else
          format.html { redirect_to admin_document_accesses_path, notice: "Document Access Links could not be destroyed." }
        end
      rescue => e
        format.html { redirect_to admin_document_accesses_path, notice: "Document Access Links could not be destroyed. #{e}" }
      end
    end

    # GET   /documents/#id/access/import
    # POST  /documents/#id/access/import
    # Imports document access links from a file provided in the params.
    def import
      logger.debug("Import Action")
      return unless params.dig(:document_access, :assets, :file)

      respond_to do |format|
        if DocumentAccess.import(params.dig(:document_access, :assets, :file))
          format.html { redirect_to admin_document_accesses_path, notice: "Document access links were created successfully." }
        else
          format.html { redirect_to admin_document_accesses_path, notice: "Access URLs could not be created." }
        end
      rescue => e
        format.html { redirect_to admin_document_accesses_path, notice: "Access URLs could not be created. #{e}" }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    # Finds and sets the document based on the document_id parameter.
    def set_document
      return unless params[:document_id] # If not nested

      @document = Document.includes(:leaf_representative).find_by!(friendlier_id: params[:document_id])
    end

    # Finds and sets the document access based on the id parameter.
    def set_document_access
      @document_access = DocumentAccess.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    # Permits only trusted parameters for document access.
    def document_access_params
      params.require(:document_access).permit(:friendlier_id, :institution_code, :access_url)
    end
  end
end
