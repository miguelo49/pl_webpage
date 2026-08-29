# frozen_string_literal: true

class InitiativePolicy < ApplicationPolicy
  def create?
    militant_or_above?
  end

  def show?
    authenticated?
  end

  def attach_documents?
    militant_or_above?
  end

  def change_status?
    authenticated? && (user.board_member? || user.technical_admin?)
  end
end
