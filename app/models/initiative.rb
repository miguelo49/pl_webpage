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
  has_many :state_changes, class_name: "InitiativeStateChange", dependent: :destroy

  attr_accessor :status_changed_by

  after_update :record_state_change, if: :saved_change_to_status?

  enum :status, {
    idea: 0,
    in_discussion: 1,
    in_development: 2,
    in_review: 3,
    approved: 4,
    rejected: 5,
    archived: 6
  }, default: :idea

  scope :by_commune, ->(commune_id) {
    commune_id.present? ? where(commune_id: commune_id) : all
  }

  scope :by_category, ->(category) {
    category.present? ? where(category: category) : all
  }

  scope :by_status, ->(status) {
    status.present? && statuses.key?(status) ? where(status: status) : all
  }

  scope :recent, -> { order(updated_at: :desc) }

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

  def record_state_change
    return unless status_changed_by

    state_changes.create!(
      previous_status: status_before_last_save,
      new_status: status,
      user: status_changed_by
    )
  end
end
