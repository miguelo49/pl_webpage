class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :ensure_onboarding_completed

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def ensure_onboarding_completed
    return unless user_signed_in?
    return if onboarding_exempt?
    return if current_user.complete?

    redirect_to onboarding_path
  end

  def onboarding_exempt?
    devise_controller? ||
      controller_name.in?(%w[onboardings authorization_test]) ||
      controller_path.start_with?("rails/health", "moderation", "admin")
  end

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_back(fallback_location: root_path)
  end
end
