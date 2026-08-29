class Initiative < ApplicationRecord
  belongs_to :user
  belongs_to :commune

  enum :status, {
    idea: 0,
    in_discussion: 1,
    in_development: 2,
    in_review: 3,
    approved: 4,
    rejected: 5,
    archived: 6
  }, default: :idea

  validates :title, presence: true
  validates :description, presence: true
  validates :problem, presence: true
  validates :proposal, presence: true
  validates :category, presence: true
  validates :user, presence: true
  validates :commune, presence: true

  def self.policy_class
    InitiativePolicy
  end
end
