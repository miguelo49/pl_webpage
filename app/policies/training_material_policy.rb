# frozen_string_literal: true

class TrainingMaterialPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def show?
    visible_material?
  end

  def download?
    show?
  end

  def create?
    authenticated? && (user.board_member? || user.technical_admin?)
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.militant_or_above?
        scope.all
      else
        scope.where(sympathizer_visible: true)
      end
    end
  end

  private

  def visible_material?
    return false unless authenticated?

    record.sympathizer_visible? || militant_or_above?
  end
end
