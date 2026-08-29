# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def create?
    authenticated?
  end
end
