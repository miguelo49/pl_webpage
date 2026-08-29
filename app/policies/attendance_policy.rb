# frozen_string_literal: true

class AttendancePolicy < ApplicationPolicy
  def create?
    authenticated?
  end

  def update?
    return false unless authenticated?

    record.user_id == user.id
  end
end
