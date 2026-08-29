module Admin
  class TrainingCategoriesController < BaseController
    before_action :set_training_category, only: [ :edit, :update, :destroy ]

    def index
      authorize :admin, :index?
      @training_categories = TrainingCategory.order(:name)
    end

    def new
      authorize :admin, :create?
      @training_category = TrainingCategory.new
    end

    def create
      authorize :admin, :create?
      @training_category = TrainingCategory.new(training_category_params)

      if @training_category.save
        redirect_to admin_training_categories_path, notice: "Categoría creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize :admin, :edit?
    end

    def update
      authorize :admin, :update?

      if @training_category.update(training_category_params)
        redirect_to admin_training_categories_path, notice: "Categoría actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize :admin, :destroy?

      if @training_category.destroy
        redirect_to admin_training_categories_path, notice: "Categoría eliminada."
      else
        redirect_to admin_training_categories_path, alert: @training_category.errors.full_messages.to_sentence
      end
    end

    private

    def set_training_category
      @training_category = TrainingCategory.find(params[:id])
    end

    def training_category_params
      params.require(:training_category).permit(:name)
    end
  end
end
