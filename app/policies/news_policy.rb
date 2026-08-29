# frozen_string_literal: true

class NewsPolicy < ApplicationPolicy
  def create?
    authenticated? && (user.board_member? || user.technical_admin?)
  end
end
