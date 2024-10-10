# frozen_string_literal: true

# Admin::ReferencesController
class Admin::ReferencesController < Admin::AdminController
  before_action :set_reference, only: %i[show edit update destroy]

  # GET /admin/references or /admin/references.json
  def index
    @references = Reference.all
  end

  # GET /admin/references/1 or /admin/references/1.json
  def show
  end

  # GET /admin/references/new
  def new
    @reference = Reference.new
  end

  # GET /admin/references/1/edit
  def edit
  end

  # POST /admin/references or /admin/references.json
  def create
    @reference = Reference.new(reference_params)

    respond_to do |format|
      if @reference.save
        format.html { redirect_to admin_reference_path(@reference), notice: "Reference was successfully created." }
        format.json { render :show, status: :created, location: @reference }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/references/1 or /admin/references/1.json
  def update
    respond_to do |format|
      if @reference.update(reference_params)
        format.html { redirect_to admin_reference_path(@reference), notice: "Reference was successfully updated." }
        format.json { render :show, status: :ok, location: @reference }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/references/1 or /admin/references/1.json
  def destroy
    @reference.destroy!

    respond_to do |format|
      format.html { redirect_to admin_references_path, status: :see_other, notice: "Reference was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def sort
    Reference.sort_elements(params[:id_list])
    render body: nil
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reference
    @reference = Reference.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def reference_params
    params.require(:reference).permit(:reference_type, :reference_uri, :label, :note, :position)
  end
end
