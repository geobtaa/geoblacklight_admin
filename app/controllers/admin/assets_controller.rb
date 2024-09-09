# frozen_string_literal: true

# Admin::AssetsController
module Admin
  class AssetsController < Admin::AdminController
    before_action :set_asset, only: %i[show edit update destroy]

    # GET /assets or /assets.json
    def index
      scope = Asset
      search_query = params[:q].strip if params[:q].present?

      # Basic search functionality
      if search_query.present?
        scope = if date_check?(search_query)
          Asset.where("created_at BETWEEN ? AND ?", search_query.to_date.beginning_of_day, search_query.to_date.end_of_day)
        else
          scope.where(id: search_query).or(
            Asset.where(friendlier_id: search_query)
          ).or(
            Asset.where("title like ?", "%" + Asset.sanitize_sql_like(search_query) + "%")
          ).or(
            Asset.where(parent_id: search_query)
          )
        end
      end

      @pagy, @assets = pagy(scope, items: 20)
    end

    # GET /assets/1 or /assets/1.json
    def show
    end

    # GET /assets/new
    def new
      @asset = Asset.new
    end

    # GET /assets/1/edit
    def edit
    end

    # POST /assets or /assets.json
    def create
      @asset = Asset.new(asset_params)

      respond_to do |format|
        if @asset.save
          format.html { redirect_to admin_asset_url(@asset), notice: "Asset was successfully created." }
          format.json { render :show, status: :created, location: @asset }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @asset.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /assets/1 or /assets/1.json
    def update
      respond_to do |format|
        if @asset.update(asset_params)
          format.html { redirect_to admin_asset_url(@asset.id), notice: "Asset was successfully updated." }
          format.json { render :show, status: :ok, location: @asset }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @asset.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /assets/1 or /assets/1.json
    def destroy
      @asset.destroy

      respond_to do |format|
        format.html { redirect_to admin_assets_url, notice: "Asset was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    # /assets/display_attach_form
    def display_attach_form
    end

    # Receives json hashes for direct uploaded files in params[:files],
    # and id in params[:id] (friendlier_id)
    # creates filesets for them and attach.
    #
    # POST /assets/ingest
    def attach_files
      # @parent = Document.find_by_friendlier_id!(params[:id])

      # current_position = @parent.members.maximum(:position) || 0

      files_params = (params[:cached_files] || [])
        .collect { |s| JSON.parse(s) }
        .sort_by { |h| h&.dig("metadata", "filename") }

      files_params.each do |file_data|
        asset = Asset.new

        # if derivative_storage_type = params.dig(:storage_type_for, file_data["id"])
        #  asset.derivative_storage_type = derivative_storage_type
        # end

        # asset.position = (current_position += 1)
        # asset.parent_id = @parent.id
        asset.file = file_data
        asset.title = (asset.file&.original_filename || "Untitled")
        asset.save!
      end

      # @parent.update(representative: @parent.members.order(:position).first) if @parent.representative_id.nil?

      redirect_to admin_assets_url, notice: "Files attached successfully."
    end

    def sort
      Asset.sort_assets(params[:id_list])
      render body: nil
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def asset_params
      params.require(:asset)
    end

    def date_check?(val)
      val.to_date
    rescue Date::Error
      false
    end
  end
end
