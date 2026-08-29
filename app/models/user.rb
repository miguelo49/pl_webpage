class User < ApplicationRecord
  ROLES = %w[sympathizer militant board_member moderator technical_admin].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    sympathizer: 0,
    militant: 1,
    board_member: 2,
    moderator: 3,
    technical_admin: 4
  }, default: :sympathizer

  validates :first_name, presence: true
  validates :last_name, presence: true

  def profile_complete?
    first_name.present? && last_name.present?
  end

  def terms_accepted?
    terms_accepted_at.present?
  end

  def onboarding_complete?
    profile_complete? && terms_accepted?
  end

  alias_method :complete?, :onboarding_complete?
end
