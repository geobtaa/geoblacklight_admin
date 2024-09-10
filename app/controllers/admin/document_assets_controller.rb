# frozen_string_literal: true

# Admin::DocumentAssetsController
module Admin
  class DocumentAssetsController < Admin::AdminController
    before_action :set_document
    before_action :set_document_asset, only: %i[show edit update destroy]

    def index
      scope = Asset

      # simple simple search on a few simple attributes with OR combo.
      if params[:document_id].present?
        document = Document.find_by_friendlier_id(params[:document_id])
        scope = scope.where(parent_id: document.id)
      end

      # scope = scope.page(params[:page]).per(20).order(created_at: :desc)
      scope = scope.includes(:parent)

      @document_assets = scope
    end

    def show
      @asset = Asset.find_by_friendlier_id!(params[:id])

      return unless @asset.stored?

      @checks = @asset.fixity_checks.order("created_at asc")
      @latest_check = @checks.last
      @earliest_check = @checks.first
    end

    def edit
    end

    # PATCH/PUT /works/1
    # PATCH/PUT /works/1.json
    def update
      @document_asset = Asset.find_by_friendlier_id!(params[:id])

      respond_to do |format|
        if @document_asset.update(document_asset_params)
          format.html { redirect_to admin_document_document_assets_path(@document_asset.parent), notice: "Asset was successfully updated." }
          format.json { render :show, status: :ok, location: @document_asset }
        else
          format.html { render :edit }
          format.json { render json: @document_asset.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @asset = Asset.find_by_friendlier_id!(params[:id])
      @asset.destroy

      respond_to do |format|
        format.html do
          redirect_to admin_document_document_assets_path(@document),
            notice: "Asset '#{@asset.title}' was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    def display_attach_form
      @document = Document.find_by_friendlier_id!(params[:document_id])
    end

    # Receives json hashes for direct uploaded files in params[:files],
    # and id in params[:id] (friendlier_id)
    # creates filesets for them and attach.
    #
    # POST /document/:id/ingest
    def attach_files
      @parent = Document.find_by_friendlier_id!(params[:id])

      current_position = @parent.members.maximum(:position) || 0

      files_params = (params[:cached_files] || [])
        .collect { |s| JSON.parse(s) }
        .sort_by { |h| h&.dig("metadata", "filename") }

      files_params.each do |file_data|
        asset = Asset.new

        # if derivative_storage_type = params.dig(:storage_type_for, file_data["id"])
        #  asset.derivative_storage_type = derivative_storage_type
        # end

        # References
        references = params.dig(:dct_references_for, file_data["id"])
        asset.dct_references_uri_key = references if references

        asset.position = (current_position += 1)
        asset.parent_id = @parent.id
        asset.file = file_data
        asset.title = (asset.file&.original_filename || "Untitled")
        asset.save!
      end

      @parent.update(representative: @parent.members.order(:position).first) if @parent.representative_id.nil?

      redirect_to admin_document_document_assets_path(@parent.friendlier_id, anchor: "nav-members")
    end

    private

    def asset_params
      allowed_params = [:title, :derivative_storage_type, :alt_text, :caption,
        :transcription, :english_translation,
        :role, {admin_note_attributes: []}, :dct_references_for]
      allowed_params << :published if can?(:publish, @asset)
      params.require(:asset).permit(*allowed_params)
    end

    def set_document
      return unless params[:document_id] # If not nested

      @document = Document.includes(:leaf_representative).find_by!(friendlier_id: params[:document_id])
    end

    def set_document_asset
      @document_asset = DocumentAsset.find_by_friendlier_id(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def document_asset_params
      params.require(:asset).permit(:title, :label, :dct_references_uri_key)
    end
  end
end
