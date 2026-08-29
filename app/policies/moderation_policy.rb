# frozen_string_literal: true

class ModerationPolicy < ApplicationPolicy
  def access?
    moderator?
  end

  alias index? access?
  alias resolve? access?
end
