class HomeController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 10

  def index
    authorize News, :index?
    @feed = ::HomeFeedQuery.new(user: current_user, page: current_page, per_page: PER_PAGE)

    respond_to do |format|
      format.html
      format.turbo_stream do
        if @feed.page > 1 && @feed.items.any?
          render :index
        else
          head :no_content
        end
      end
    end
  end

  private

  def current_page
    [ params[:page].to_i, 1 ].max
  end
end
