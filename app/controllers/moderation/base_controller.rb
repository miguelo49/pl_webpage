module Moderation
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_moderator!

    private

    def authorize_moderator!
      authorize :moderation, :access?
    end
  end
end
