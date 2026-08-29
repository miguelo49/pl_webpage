class AuditLog < ApplicationRecord
  ACTIONS = %w[role_changed activated deactivated].freeze

  belongs_to :actor, class_name: "User"
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :actor, presence: true
  validates :auditable, presence: true

  def details
    return {} if change_details.blank?

    JSON.parse(change_details)
  rescue JSON::ParserError
    {}
  end
end
