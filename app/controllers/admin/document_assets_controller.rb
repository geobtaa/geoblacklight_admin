# frozen_string_literal: true

# Admin::DocumentAssetsController
module Admin
  class DocumentAssetsController < Admin::AdminController
    before_action :set_document

    def index
      scope = Kithe::Asset

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
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:id])
      authorize! :read, @asset

      return unless @asset.stored?

      @checks = @asset.fixity_checks.order("created_at asc")
      @latest_check = @checks.last
      @earliest_check = @checks.first
    end

    def edit
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:id])
      authorize! :update, @asset
    end

    # PATCH/PUT /works/1
    # PATCH/PUT /works/1.json
    def update
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:id])
      authorize! :update, @asset

      respond_to do |format|
        if @asset.update(asset_params)
          format.html { redirect_to admin_asset_url(@asset), notice: "Asset was successfully updated." }
          format.json { render :show, status: :ok, location: @asset }
        else
          format.html { render :edit }
          format.json { render json: @asset.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:id])
      @asset.destroy

      respond_to do |format|
        format.html do
          redirect_to document_document_assets_path(@document),
            notice: "Asset '#{@asset.title}' was successfully destroyed."
        end
        format.json { head :no_content }
      end
    end

    def check_fixity
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:asset_id])
      SingleAssetCheckerJob.perform_later(@asset)
      redirect_to admin_asset_url(@asset), notice: "This file will be checked shortly."
    end

    def fixity_report
      @fixity_report = FixityReport.new
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
        asset = Kithe::Asset.new

        # if derivative_storage_type = params.dig(:storage_type_for, file_data["id"])
        #  asset.derivative_storage_type = derivative_storage_type
        # end

        asset.position = (current_position += 1)
        asset.parent_id = @parent.id
        asset.file = file_data
        asset.title = (asset.file&.original_filename || "Untitled")
        asset.save!
      end

      @parent.update(representative: @parent.members.order(:position).first) if @parent.representative_id.nil?

      redirect_to admin_document_path(@parent.friendlier_id, anchor: "nav-members")
    end

    def convert_to_child_work
      @asset = Kithe::Asset.find_by_friendlier_id!(params[:id])

      parent = @asset.parent

      new_child = Work.new(title: @asset.title)

      # Asking for permission to create a new Work,
      # which is arguably the main thing going on in this method.
      # authorize! :create, Work as the first line of the method
      # would be better, but we currently aren't allowed to do that
      # see (https://github.com/chaps-io/access-granted/pull/56).
      authorize! :create, new_child

      new_child.parent = parent
      # collections
      new_child.contained_by = parent.contained_by
      new_child.position = @asset.position
      new_child.representative = @asset
      # we can copy _all_ the non-title metadata like this...
      new_child.json_attributes = parent.json_attributes

      @asset.parent = new_child

      Kithe::Model.transaction do
        new_child.save!
        @asset.save! # to get new parent

        if parent.representative_id == @asset.id
          parent.representative = new_child
          parent.save!
        end
      end

      redirect_to edit_admin_work_path(new_child), notice: "Asset promoted to child work #{new_child.title}"
    end

    # requires params[:active_encode_status_id]
    def refresh_active_encode_status
      status = ActiveEncodeStatus.find(params[:active_encode_status_id])

      RefreshActiveEncodeStatusJob.perform_later(status)

      redirect_to admin_asset_url(status.asset),
        notice: "Started refresh for ActiveEncode job #{status.active_encode_id}"
    end

    def work_is_oral_history?
      (@asset.parent.is_a? Work) && @asset.parent.genre && @asset.parent.genre.include?("Oral histories")
    end
    helper_method :work_is_oral_history?

    def asset_is_collection_thumbnail?
      @asset.parent.is_a? Collection
    end
    helper_method :asset_is_collection_thumbnail?

    def edit_path(asset)
      asset.parent.is_a? Collection ? edit_admin_collection_path(asset.parent) : edit_admin_asset_path(asset)
    end
    helper_method :edit_path

    def parent_path(asset)
      return nil if asset.parent.nil?

      asset.parent.is_a? Collection ? collection_path(asset.parent) : admin_work_path(asset.parent)
    end
    helper_method :parent_path

    private

    def set_document
      return unless params[:document_id] # If not nested

      @document = Document.includes(:leaf_representative).find_by!(friendlier_id: params[:document_id])
    end

    def asset_params
      allowed_params = [:title, :derivative_storage_type, :alt_text, :caption,
        :transcription, :english_translation,
        :role, {admin_note_attributes: []}]
      allowed_params << :published if can?(:publish, @asset)
      params.require(:asset).permit(*allowed_params)
    end
  end
end
