# frozen_string_literal: true

class ThreadPolicy < ApplicationPolicy
  def create?
    return false unless authenticated?
    return false if record.topic&.news_topic?

    true
  end

  def update?
    return false unless authenticated?

    record.user_id == user.id || manage_audience?
  end

  def manage_audience?
    return false unless authenticated?

    user.board_member? || user.moderator? || user.technical_admin?
  end

  def index?
    authenticated?
  end

  def show?
    return false unless authenticated?

    return true if manage_audience?

    return true if record.user_id.present? && record.user_id == user.id

    return false unless record.approved?

    audience_visible?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.board_member? || user.moderator? || user.technical_admin?
        scope.all
      elsif user.militant_or_above?
        scope.publicly_visible
      else
        scope.publicly_visible.where(sympathizer_visible: true)
      end
    end
  end

  private

  def audience_visible?
    record.sympathizer_visible? || militant_or_above?
  end
end
