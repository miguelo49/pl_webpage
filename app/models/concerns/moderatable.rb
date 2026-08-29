module Moderatable
  extend ActiveSupport::Concern

  included do
    has_many :reports, as: :reportable, dependent: :destroy
    has_many :moderation_logs, as: :moderatable, dependent: :destroy

    attr_accessor :moderated_by, :moderation_rejection_reason

    after_update :record_moderation_log, if: :should_record_moderation_log?
  end

  private

  def should_record_moderation_log?
    saved_change_to_status? && moderated_by.present? && moderation_actor?(moderated_by)
  end

  def moderation_actor?(user)
    user.board_member? || user.moderator? || user.technical_admin?
  end

  def record_moderation_log
    moderation_logs.create!(
      moderator: moderated_by,
      action: moderation_action_for_status.to_s,
      rejection_reason: moderation_rejection_reason.presence
    )
  end

  def moderation_action_for_status
    case status.to_sym
    when :approved then :approve
    when :rejected then :reject
    when :hidden then :hide
    when :reported then :mark_reported
    else :update_status
    end
  end
end
