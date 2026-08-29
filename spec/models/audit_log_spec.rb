require "rails_helper"

RSpec.describe AuditLog, type: :model do
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  let(:admin) do
    User.create!(
      email: "audit-admin@example.com",
      password: "password123",
      first_name: "Admin",
      last_name: "Técnico",
      role: :technical_admin,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  let(:target) do
    User.create!(
      email: "audit-target@example.com",
      password: "password123",
      first_name: "Usuario",
      last_name: "Objetivo",
      role: :sympathizer,
      terms_accepted_at: Time.current
    )
  end

  it "is created when an admin changes a user role" do
    target.audit_actor = admin
    target.residence_commune = commune

    expect {
      target.update!(role: :militant)
    }.to change(described_class, :count).by(1)

    log = described_class.last
    expect(log.action).to eq("role_changed")
    expect(log.details["new_role"]).to eq("militant")
  end
end
