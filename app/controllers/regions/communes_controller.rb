module Regions
  class CommunesController < ApplicationController
    before_action :authenticate_user!

    def index
      region = Region.find(params[:region_id])
      communes = region.communes.order(:name).select(:id, :name)

      render json: communes
    end
  end
end
