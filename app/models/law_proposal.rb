class LawProposal < ApplicationRecord
  belongs_to :user
  belongs_to :commune

  has_many :versions, class_name: "LawProposalVersion", dependent: :destroy

  attr_accessor :text_edited_by

  after_update :record_text_version, if: :saved_change_to_current_text?

  enum :status, {
    idea: 0,
    discussion: 1,
    collaborative_development: 2,
    review: 3,
    consolidated_proposal: 4,
    political_review: 5,
    result: 6
  }, default: :idea

  validates :name, presence: true
  validates :problem, presence: true
  validates :rationale, presence: true
  validates :objective, presence: true
  validates :current_text, presence: true
  validates :category, presence: true
  validates :user, presence: true
  validates :commune, presence: true

  def self.policy_class
    LawProposalPolicy
  end

  private

  def record_text_version
    return unless text_edited_by

    versions.create!(
      text: current_text_before_last_save,
      user: text_edited_by
    )
  end
end
