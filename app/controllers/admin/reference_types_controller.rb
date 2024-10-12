# frozen_string_literal: true

# Admin::ReferenceTypesController
class Admin::ReferenceTypesController < Admin::AdminController
  before_action :set_reference_type, only: %i[show edit update destroy]

  # GET /admin/reference_types or /admin/reference_types.json
  def index
    @reference_types = ReferenceType.all
  end

  # GET /admin/reference_types/1 or /admin/reference_types/1.json
  def show
  end

  # GET /admin/reference_types/new
  def new
    @reference_type = ReferenceType.new
  end

  # GET /admin/reference_types/1/edit
  def edit
  end

  # POST /admin/reference_types or /admin/reference_types.json
  def create
    @reference_type = ReferenceType.new(reference_type_params)

    respond_to do |format|
      if @reference_type.save
        format.html { redirect_to admin_reference_type_path(@reference_type), notice: "Reference type was successfully created." }
        format.json { render :show, status: :created, location: @reference_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reference_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/reference_types/1 or /admin/reference_types/1.json
  def update
    respond_to do |format|
      if @reference_type.update(reference_type_params)
        format.html { redirect_to admin_reference_type_path(@reference_type), notice: "Reference type was successfully updated." }
        format.json { render :show, status: :ok, location: @reference_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reference_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/reference_types/1 or /admin/reference_types/1.json
  def destroy
    @reference_type.destroy!

    respond_to do |format|
      format.html { redirect_to admin_reference_types_path, status: :see_other, notice: "Reference type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def sort
    ReferenceType.sort_elements(params[:id_list])
    render body: nil
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reference_type
    @reference_type = ReferenceType.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def reference_type_params
    params.require(:reference_type).permit(:name, :reference_type, :reference_uri, :label, :note, :position)
  end
end
