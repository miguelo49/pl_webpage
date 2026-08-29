class TopicsController < ApplicationController
  before_action :authenticate_user!

  def index
    @topics = Topic.ordered
  end
end
