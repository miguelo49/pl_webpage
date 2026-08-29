# frozen_string_literal: true

class TrainingMaterialPolicy < ApplicationPolicy
  def index?
    authenticated?
  end

  def create?
    authenticated? && (user.board_member? || user.technical_admin?)
  end
end
