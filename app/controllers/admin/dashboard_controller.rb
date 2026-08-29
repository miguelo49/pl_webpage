module Admin
  class DashboardController < BaseController
    def index
      authorize :admin, :index?
    end
  end
end
