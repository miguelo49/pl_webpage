class ModerationLog < ApplicationRecord
  ACTIONS = %w[approve reject hide mark_reported restore update_status].freeze

  belongs_to :moderator, class_name: "User"
  belongs_to :moderatable, polymorphic: true

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :moderator, presence: true
  validates :moderatable, presence: true

  def approve?
    action == "approve"
  end

  def reject?
    action == "reject"
  end
end
