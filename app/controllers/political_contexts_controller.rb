class PoliticalContextsController < ApplicationController
  NEWS_LIMIT = 8
  EVENTS_LIMIT = 10

  before_action :authenticate_user!

  def index
    authorize News, :index?

    @news_items = policy_scope(News)
      .for_political_context
      .includes(:user, featured_image_attachment: :blob)
      .recent
      .limit(NEWS_LIMIT)

    @upcoming_events = Event.upcoming
      .includes(:organizer, :commune)
      .limit(EVENTS_LIMIT)
  end
end
