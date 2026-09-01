# frozen_string_literal: true

class NewsPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def show?
    return false unless authenticated?

    return true if record.approved?

    user.board_member? || user.technical_admin?
  end

  def create?
    authenticated? && (user.board_member? || user.technical_admin?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.board_member? || user.technical_admin?
        scope.all
      else
        scope.publicly_visible
      end
    end
  end
end
