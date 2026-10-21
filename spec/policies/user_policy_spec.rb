require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  def build_user(role)
    User.new(
      role: role,
      email: "#{role}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  describe "#assignable_roles" do
    it "returns all roles for technical admins" do
      actor = build_user(:technical_admin)
      policy = described_class.new(actor, User.new)

      expect(policy.assignable_roles).to match_array(User.roles.keys)
    end

    it "returns only sympathizer and militant for moderators" do
      actor = build_user(:moderator)
      policy = described_class.new(actor, User.new)

      expect(policy.assignable_roles).to eq(%w[sympathizer militant])
    end
  end
end
