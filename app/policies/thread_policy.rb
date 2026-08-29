# frozen_string_literal: true

class ThreadPolicy < ApplicationPolicy
  def create?
    authenticated?
  end

  def update?
    return false unless authenticated?

    record.user_id == user.id || user.board_member? || user.moderator?
  end

  def index?
    authenticated?
  end

  def show?
    return false unless authenticated?

    return true if record.approved?
    return true if record.user_id == user.id

    user.board_member? || user.moderator? || user.technical_admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.board_member? || user.moderator? || user.technical_admin?
        scope.all
      else
        scope.publicly_visible
      end
    end
  end
end
