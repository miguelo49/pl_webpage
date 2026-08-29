# frozen_string_literal: true

class AuthorizationTestPolicy < ApplicationPolicy
  def index?
    militant_or_above?
  end
end
