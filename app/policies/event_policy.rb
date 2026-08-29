# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def create?
    authenticated? && (user.board_member? || user.technical_admin?)
  end
end
