# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  ELEVATION_ROLES = %w[sympathizer militant].freeze

  def index?
    staff_user_management?
  end

  def edit?
    manage_user?
  end

  def update?
    manage_user?
  end

  def assignable_roles
    return User.roles.keys if user.technical_admin?
    return ELEVATION_ROLES if user.board_member? || user.moderator?

    []
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.technical_admin?
        scope.all
      elsif user.moderator?
        scope.where.not(role: :technical_admin)
      elsif user.board_member?
        scope.where(role: ELEVATION_ROLES)
      else
        scope.none
      end
    end
  end

  private

  def staff_user_management?
    user.technical_admin? || user.moderator? || user.board_member?
  end

  def manage_user?
    return false unless staff_user_management?
    return false unless record.is_a?(User) && record.persisted?

    return true if user.technical_admin?
    return false if record.technical_admin? || record.moderator? || record.board_member?

    true
  end
end
