class News < ApplicationRecord
  belongs_to :user

  enum :category, {
    party: 0,
    regional: 1,
    national: 2,
    legislative: 3,
    analysis: 4,
    statement: 5,
    activity: 6
  }

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    reported: 3,
    hidden: 4
  }, default: :approved

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true
  validates :category, presence: true
  validate :acceptable_featured_image

  scope :publicly_visible, -> { approved }
  scope :recent, -> { order(Arel.sql("COALESCE(published_at, created_at) DESC")) }

  has_one_attached :featured_image

  def self.policy_class
    NewsPolicy
  end

  def publicly_visible?
    approved?
  end

  private

  def acceptable_featured_image
    return unless featured_image.attached?

    unless featured_image.content_type.in?(User::ACCEPTED_AVATAR_TYPES)
      errors.add(:featured_image, "must be a JPEG, PNG, WebP, or GIF")
    end
  end
end
