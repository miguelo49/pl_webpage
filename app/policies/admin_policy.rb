# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def access?
    admin?
  end

  alias index? access?
  alias create? access?
  alias update? access?
  alias destroy? access?
  alias edit? access?
end
