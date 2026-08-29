class Initiative < ApplicationRecord
  ACCEPTED_DOCUMENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  belongs_to :user
  belongs_to :commune

  has_many_attached :documents
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy

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

  validate :acceptable_documents

  def self.policy_class
    InitiativePolicy
  end

  private

  def acceptable_documents
    documents.each do |document|
      next if document.content_type.in?(ACCEPTED_DOCUMENT_TYPES)

      errors.add(:documents, "must be a PDF or Word document")
    end
  end
end
