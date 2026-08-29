class TrainingMaterialsController < ApplicationController
  include BookmarkHandling
  include ReadMarkHandling

  before_action :authenticate_user!
  before_action :set_training_material, only: [ :bookmark, :read_mark ]

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
    @training_material = TrainingMaterial.find(params[:id])
  end
end
