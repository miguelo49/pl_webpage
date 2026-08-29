class LawProposalVersion < ApplicationRecord
  belongs_to :law_proposal
  belongs_to :user

  validates :text, presence: true
  validates :user, presence: true
  validates :law_proposal, presence: true
end
