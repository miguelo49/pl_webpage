# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def militant_or_above?
    authenticated? && role_rank >= role_rank_for("militant")
  end

  def board_or_above?
    authenticated? && role_rank >= role_rank_for("board_member")
  end

  def moderator?
    authenticated? && role_rank >= role_rank_for("moderator")
  end

  def admin?
    authenticated? && user.technical_admin?
  end

  def authenticated?
    user.present?
  end

  def role_rank
    User::ROLES.index(user.role)
  end

  def role_rank_for(role_name)
    User::ROLES.index(role_name)
  end
end
