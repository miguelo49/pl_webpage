# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def create?
    militant_or_above?
  end

  def show?
    return false unless authenticated?

    return true if record.approved?

    record.organizer == user || user.moderator? || user.technical_admin?
  end

  def index?
    authenticated?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      upcoming = scope.upcoming

      if user.moderator? || user.technical_admin?
        upcoming
      else
        upcoming.where(status: :approved).or(upcoming.where(organizer_id: user.id))
      end
    end
  end
end
