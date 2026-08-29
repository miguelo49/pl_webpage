module Admin
  class CommunesController < BaseController
    before_action :set_commune, only: [ :edit, :update, :destroy ]

    def index
      authorize :admin, :index?
      @communes = Commune.joins(:region).includes(:region).order("regions.name", "communes.name")
    end

    def new
      authorize :admin, :create?
      @commune = Commune.new
      @regions = Region.order(:name)
    end

    def create
      authorize :admin, :create?
      @commune = Commune.new(commune_params)
      @regions = Region.order(:name)

      if @commune.save
        redirect_to admin_communes_path, notice: "Comuna creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize :admin, :edit?
      @regions = Region.order(:name)
    end

    def update
      authorize :admin, :update?
      @regions = Region.order(:name)

      if @commune.update(commune_params)
        redirect_to admin_communes_path, notice: "Comuna actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize :admin, :destroy?

      if @commune.destroy
        redirect_to admin_communes_path, notice: "Comuna eliminada."
      else
        redirect_to admin_communes_path, alert: @commune.errors.full_messages.to_sentence
      end
    end

    private

    def set_commune
      @commune = Commune.find(params[:id])
    end

    def commune_params
      params.require(:commune).permit(:name, :region_id)
    end
  end
end
