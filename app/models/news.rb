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

  scope :publicly_visible, -> { approved }

  def self.policy_class
    NewsPolicy
  end

  def publicly_visible?
    approved?
  end
end
