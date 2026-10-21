module UserRoleManagement
  extend ActiveSupport::Concern

  private

  def assign_user_role_and_active(user, allowed_roles: User.roles.keys)
    role = params.dig(:user, :role)
    user.role = role if role.present? && role.in?(allowed_roles)

    return unless params[:user].key?(:active)

    user.active = ActiveModel::Type::Boolean.new.cast(params[:user][:active])
  end

  def ensure_commune_for_militant_role(user)
    return unless user.militant_or_above?
    return if user.residence_commune_id.present?

    user.residence_commune = current_user.residence_commune || Commune.first
  end
end
