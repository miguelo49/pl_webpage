class TrainingMaterialsController < ApplicationController
  include BookmarkHandling
  include ReadMarkHandling

  before_action :authenticate_user!
  before_action :set_training_material, only: [ :show, :download, :bookmark, :read_mark ]

  def index
    authorize TrainingMaterial

    @query = params[:q].to_s.strip
    @selected_category_id = params[:training_category_id]
    @training_categories = TrainingCategory.order(:name)

    @training_materials = TrainingMaterial
      .includes(:training_category, :bookmarks, :read_marks, cover_image_attachment: :blob)
      .search_by(@query)
      .by_category(@selected_category_id)
      .library_order
  end

  def show
    authorize @training_material
  end

  def download
    authorize @training_material, :download?

    unless @training_material.pdf.attached?
      redirect_to training_material_path(@training_material), alert: "Este material no tiene un PDF disponible."
      return
    end

    redirect_to rails_blob_path(@training_material.pdf, disposition: :attachment),
                allow_other_host: true
  end

  def bookmark
    authorize @training_material, :index?
    toggle_bookmark(@training_material)
  end

  def read_mark
    authorize @training_material, :index?
    toggle_read_mark(@training_material)
  end

  private

  def set_training_material
    @training_material = TrainingMaterial
      .includes(:training_category, :bookmarks, :read_marks, pdf_attachment: :blob, cover_image_attachment: :blob)
      .find(params[:id])
  end
end
