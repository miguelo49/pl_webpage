module Admin
  class RegionsController < BaseController
    before_action :set_region, only: [ :edit, :update, :destroy ]

    def index
      authorize :admin, :index?
      @regions = Region.order(:name)
    end

    def new
      authorize :admin, :create?
      @region = Region.new
    end

    def create
      authorize :admin, :create?
      @region = Region.new(region_params)

      if @region.save
        redirect_to admin_regions_path, notice: "Región creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize :admin, :edit?
    end

    def update
      authorize :admin, :update?

      if @region.update(region_params)
        redirect_to admin_regions_path, notice: "Región actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize :admin, :destroy?

      if @region.destroy
        redirect_to admin_regions_path, notice: "Región eliminada."
      else
        redirect_to admin_regions_path, alert: @region.errors.full_messages.to_sentence
      end
    end

    private

    def set_region
      @region = Region.find(params[:id])
    end

    def region_params
      params.require(:region).permit(:name)
    end
  end
end
