module Moderation
  class ReportsController < BaseController
    def index
      authorize :moderation, :index?
      @reports = Report.includes(:user, :reportable).order(created_at: :desc)
    end
  end
end
