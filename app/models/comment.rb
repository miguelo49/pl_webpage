class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    reported: 3,
    hidden: 4
  }, default: :pending

  validates :body, presence: true
  validate :parent_must_be_top_level, if: -> { parent_id.present? }
  validate :parent_matches_commentable, if: -> { parent_id.present? }

  scope :top_level, -> { where(parent_id: nil) }
  scope :publicly_visible, -> { approved }

  def reply?
    parent_id.present?
  end

  def publicly_visible?
    approved?
  end

  private

  def parent_must_be_top_level
    return unless parent&.parent_id.present?

    errors.add(:parent, "cannot be a reply")
  end

  def parent_matches_commentable
    return unless parent
    return if parent.commentable_type == commentable_type && parent.commentable_id == commentable_id

    errors.add(:parent, "must belong to the same commentable")
  end
end
