# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  MODERATOR_ASSIGNABLE_ROLES = %w[sympathizer militant board_member moderator].freeze

  def index?
    moderator?
  end

  def edit?
    manage_user?
  end

  def update?
    manage_user?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.none unless user.moderator? || user.technical_admin?

      if user.technical_admin?
        scope.all
      else
        scope.where.not(role: :technical_admin)
      end
    end
  end

  private

  def manage_user?
    return false unless moderator?
    return false unless record.is_a?(User) && record.persisted?

    !record.technical_admin?
  end
end
