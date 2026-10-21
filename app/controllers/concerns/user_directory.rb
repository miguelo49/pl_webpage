# frozen_string_literal: true

module UserDirectory
  extend ActiveSupport::Concern

  private

  def load_users_directory
    @query = params[:q].to_s.strip
    @users = policy_scope(User).order(:last_name, :first_name, :email)

    if @query.present?
      pattern = "%#{User.sanitize_sql_like(@query)}%"
      @users = @users.where("email ILIKE :pattern OR rut ILIKE :pattern", pattern: pattern)
    end
  end
end
