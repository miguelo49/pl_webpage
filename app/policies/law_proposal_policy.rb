# frozen_string_literal: true

class LawProposalPolicy < ApplicationPolicy
  def create?
    militant_or_above?
  end

  def show?
    authenticated?
  end

  def index?
    show?
  end

  def update?
    authenticated? && (record.user_id == user.id || user.board_member? || user.technical_admin?)
  end
end
