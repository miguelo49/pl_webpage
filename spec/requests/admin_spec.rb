require "rails_helper"

RSpec.describe "Admin panel", type: :request do
  let(:password) { "password123" }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  def create_user(role:, email: nil, active: true)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      active: active,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      attrs[:residence_commune] = commune
    end

    User.create!(attrs)
  end

  describe "GET /admin" do
    it "denies access to a militant" do
      user = create_user(role: :militant)
      sign_in user

      get admin_root_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("No tienes permiso para realizar esta acción.")
    end

    it "allows a technical admin to access the dashboard" do
      admin = create_user(role: :technical_admin)
      sign_in admin

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Administración técnica")
    end
  end

  describe "PATCH /admin/users/:id" do
    it "changes a user role, records audit log, and updates permissions immediately" do
      admin = create_user(role: :technical_admin, email: "admin@example.com")
      target = create_user(role: :sympathizer, email: "target@example.com")

      sign_in admin

      expect {
        patch admin_user_path(target), params: { user: { role: "moderator", active: "1" } }
      }.to change(AuditLog, :count).by(1)

      target.reload
      expect(target.role).to eq("moderator")
      expect(ModerationPolicy.new(target, :moderation).access?).to be true

      audit_log = AuditLog.last
      expect(audit_log.action).to eq("role_changed")
      expect(audit_log.actor).to eq(admin)
      expect(audit_log.auditable).to eq(target)
      expect(audit_log.details["previous_role"]).to eq("sympathizer")
      expect(audit_log.details["new_role"]).to eq("moderator")
    end

    it "records deactivation in the audit log" do
      admin = create_user(role: :technical_admin, email: "admin-deactivate@example.com")
      target = create_user(role: :militant, email: "deactivate-target@example.com")

      sign_in admin

      expect {
        patch admin_user_path(target), params: { user: { role: "militant", active: "0" } }
      }.to change(AuditLog, :count).by(1)

      expect(target.reload.active?).to be false
      expect(AuditLog.last.action).to eq("deactivated")
    end
  end
end
