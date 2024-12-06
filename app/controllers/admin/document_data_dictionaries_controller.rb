module Admin
  class DocumentDataDictionariesController < ApplicationController
    before_action :set_document
    before_action :set_document_data_dictionary, only: %i[ show edit update destroy ]

    # GET /document_data_dictionaries or /document_data_dictionaries.json
    def index
      @document_data_dictionaries = DocumentDataDictionary.all
      if params[:document_id]
        @document_data_dictionaries = DocumentDataDictionary.where(friendlier_id: @document.friendlier_id).order(position: :asc)
      else
        @pagy, @document_data_dictionaries = pagy(DocumentDataDictionary.all.order(friendlier_id: :asc, updated_at: :desc), items: 20)
      end
    end

    # GET /document_data_dictionaries/1 or /document_data_dictionaries/1.json
    def show
    end

    # GET /document_data_dictionaries/new
    def new
      @document_data_dictionary = DocumentDataDictionary.new
    end

    # GET /document_data_dictionaries/1/edit
    def edit
    end

    # POST /document_data_dictionaries or /document_data_dictionaries.json
    def create
      @document_data_dictionary = DocumentDataDictionary.new(document_data_dictionary_params)

      respond_to do |format|
        if @document_data_dictionary.save
          format.html { redirect_to admin_document_document_data_dictionaries_path(@document), notice: "Document data dictionary was successfully created." }
          format.json { render :show, status: :created, location: @document_data_dictionary }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @document_data_dictionary.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /document_data_dictionaries/1 or /document_data_dictionaries/1.json
    def update
      respond_to do |format|
        if @document_data_dictionary.update(document_data_dictionary_params)
          format.html { redirect_to admin_document_document_data_dictionaries_path(@document), notice: "Document data dictionary was successfully updated." }
          format.json { render :show, status: :ok, location: @document_data_dictionary }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @document_data_dictionary.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /document_data_dictionaries/1 or /document_data_dictionaries/1.json
    def destroy
      @document_data_dictionary.destroy!

      respond_to do |format|
        format.html { redirect_to admin_document_document_data_dictionaries_path(@document), status: :see_other, notice: "Document data dictionary was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    # DELETE /admin/document_data_dictionaries/destroy_all
    #
    # Destroys all document data dictionaries provided in the file parameter. If successful, redirects
    # with a success notice. Otherwise, redirects with an error notice.
    def destroy_all
      return if request.get?

      logger.debug("Destroy Data Dictionaries")
      unless params.dig(:document_data_dictionary, :data_dictionaries, :file)
        raise ArgumentError, "File does not exist or is invalid."
      end

      respond_to do |format|
        if DocumentDataDictionary.destroy_all(params.dig(:document_data_dictionary, :data_dictionaries, :file))
          format.html { redirect_to admin_document_document_data_dictionaries_path, notice: "Data dictionaries were destroyed." }
        else
          format.html { redirect_to admin_document_document_data_dictionaries_path, notice: "Data dictionaries could not be destroyed." }
        end
      rescue => e
        format.html { redirect_to admin_document_document_data_dictionaries_path, notice: "Data dictionaries could not be destroyed. #{e}" }
      end
    end

    # GET/POST /documents/1/data_dictionaries/import
    #
    # Imports document data dictionaries from a file. If successful, redirects with a success notice.
    # Otherwise, redirects with an error notice.
    def import
      return if request.get?

      logger.debug("Import Data Dictionaries")

      unless params.dig(:document_data_dictionary, :data_dictionaries, :file)
        raise ArgumentError, "File does not exist or is invalid."
      end

      if DocumentDataDictionary.import(params.dig(:document_data_dictionary, :data_dictionaries, :file))
        logger.debug("Data dictionaries were created successfully.")
        if params[:document_id]
          redirect_to admin_document_document_data_dictionaries_path(@document), notice: "Data dictionaries were created successfully."
        else
          redirect_to admin_document_document_data_dictionaries_path, notice: "Data dictionaries were created successfully."
        end
      else
        logger.debug("Data dictionaries could not be created.")
        if params[:document_id]
          redirect_to admin_document_document_data_dictionaries_path(@document), warning: "Data dictionaries could not be created."
        else
          redirect_to admin_document_document_data_dictionaries_path, warning: "Data dictionaries could not be created."
        end
      end
    rescue => e
      logger.debug("Data dictionaries could not be created. #{e}")
      if params[:document_id]
        redirect_to admin_document_document_data_dictionaries_path(@document), notice: "Data dictionaries could not be created. #{e}"
      else
        redirect_to admin_document_document_data_dictionaries_path, notice: "Data dictionaries could not be created. #{e}"
      end
    end

    private

    # Sets the document based on the document_id parameter.
    # If not nested, it does nothing.
    def set_document
      return unless params[:document_id] # If not nested

      @document = Document.includes(:leaf_representative).find_by!(friendlier_id: params[:document_id])
    end

    # Sets the document data dictionary based on the id parameter.
    def set_document_data_dictionary
      @document_data_dictionary = DocumentDataDictionary.find(params[:id])
    end

      # Only allow a list of trusted parameters through.
    def document_data_dictionary_params
      params.require(:document_data_dictionary).permit(:friendlier_id, :label, :type, :values, :definition, :definition_source, :parent_friendlier_id, :position)
    end
  end
end