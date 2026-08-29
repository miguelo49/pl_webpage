class User < ApplicationRecord
  ROLES = %w[sympathizer militant board_member moderator technical_admin].freeze

  ACCEPTED_AVATAR_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :threads, class_name: "ForumThread", dependent: :restrict_with_error
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  belongs_to :residence_commune, class_name: "Commune", optional: true
  belongs_to :work_commune, class_name: "Commune", optional: true
  belongs_to :study_commune, class_name: "Commune", optional: true

  enum :role, {
    sympathizer: 0,
    militant: 1,
    board_member: 2,
    moderator: 3,
    technical_admin: 4
  }, default: :sympathizer

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :residence_commune, presence: true, if: :militant_or_above?
  validate :acceptable_avatar

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

  def full_name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def militant_or_above?
    ROLES.index(role) >= ROLES.index("militant")
  end

  private

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.content_type.in?(ACCEPTED_AVATAR_TYPES)
      errors.add(:avatar, "must be a JPEG, PNG, WebP, or GIF")
    end
  end
end
