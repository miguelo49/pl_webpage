module AuditableAdminChanges
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy

    attr_accessor :audit_actor

    after_update :record_admin_audit_log
  end

  private

  def record_admin_audit_log
    return unless audit_actor&.technical_admin?

    if saved_change_to_role?
      audit_logs.create!(
        actor: audit_actor,
        action: "role_changed",
        change_details: {
          previous_role: role_before_last_save,
          new_role: role
        }.to_json
      )
    elsif saved_change_to_active?
      audit_logs.create!(
        actor: audit_actor,
        action: active? ? "activated" : "deactivated",
        change_details: {
          previous_active: active_before_last_save,
          new_active: active
        }.to_json
      )
    end
  end
end
