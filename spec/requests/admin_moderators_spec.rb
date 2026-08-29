require "rails_helper"

RSpec.describe "Admin moderators", type: :request do
  let(:password) { "password123" }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  def create_user(role:, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      attrs[:residence_commune] = commune
    end

    User.create!(attrs)
  end

  describe "POST /admin/moderators" do
    it "assigns the moderator role and records an audit log" do
      admin = create_user(role: :technical_admin, email: "moderator-admin@example.com")
      militant = create_user(role: :militant, email: "future-moderator@example.com")

      sign_in admin

      expect {
        post admin_moderators_path, params: { id: militant.id }
      }.to change(AuditLog, :count).by(1)

      militant.reload
      expect(militant.role).to eq("moderator")
      expect(ModerationPolicy.new(militant, :moderation).access?).to be true

      audit_log = AuditLog.last
      expect(audit_log.action).to eq("role_changed")
      expect(audit_log.actor).to eq(admin)
      expect(audit_log.auditable).to eq(militant)
      expect(audit_log.details["previous_role"]).to eq("militant")
      expect(audit_log.details["new_role"]).to eq("moderator")
    end

    it "assigns moderator from board_member without changing other attributes" do
      admin = create_user(role: :technical_admin, email: "moderator-admin-2@example.com")
      board_member = create_user(role: :board_member, email: "board-to-mod@example.com")
      original_first_name = board_member.first_name

      sign_in admin

      post admin_moderators_path, params: { id: board_member.id }

      board_member.reload
      expect(board_member.role).to eq("moderator")
      expect(board_member.first_name).to eq(original_first_name)
    end
  end

  describe "DELETE /admin/moderators/:id" do
    it "revokes the moderator role and records an audit log" do
      admin = create_user(role: :technical_admin, email: "revoke-admin@example.com")
      moderator = create_user(role: :moderator, email: "revoke-moderator@example.com")

      sign_in admin

      expect {
        delete admin_moderator_path(moderator), params: { restore_role: "militant" }
      }.to change(AuditLog, :count).by(1)

      moderator.reload
      expect(moderator.role).to eq("militant")
      expect(ModerationPolicy.new(moderator, :moderation).access?).to be false

      audit_log = AuditLog.last
      expect(audit_log.action).to eq("role_changed")
      expect(audit_log.details["previous_role"]).to eq("moderator")
      expect(audit_log.details["new_role"]).to eq("militant")
    end

    it "can restore a moderator to board_member" do
      admin = create_user(role: :technical_admin, email: "restore-board-admin@example.com")
      moderator = create_user(role: :moderator, email: "restore-board-mod@example.com")

      sign_in admin

      delete admin_moderator_path(moderator), params: { restore_role: "board_member" }

      expect(moderator.reload.role).to eq("board_member")
    end
  end
end
