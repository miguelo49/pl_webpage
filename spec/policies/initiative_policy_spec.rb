require "rails_helper"

RSpec.describe InitiativePolicy, type: :policy do
  def build_user(role)
    User.new(
      role: role,
      email: "#{role}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  describe "#create?" do
    subject(:policy) { described_class.new(user, Initiative.new) }

    context "when user is not authenticated" do
      let(:user) { nil }

      it { expect(policy.create?).to be false }
    end

    context "when user is a sympathizer" do
      let(:user) { build_user(:sympathizer) }

      it { expect(policy.create?).to be false }
    end

    context "when user is a militant" do
      let(:user) { build_user(:militant) }

      it { expect(policy.create?).to be true }
    end

    context "when user is a moderator" do
      let(:user) { build_user(:moderator) }

      it { expect(policy.create?).to be true }
    end

    context "when user is a board member" do
      let(:user) { build_user(:board_member) }

      it { expect(policy.create?).to be true }
    end

    context "when user is a technical admin" do
      let(:user) { build_user(:technical_admin) }

      it { expect(policy.create?).to be true }
    end
  end

  describe "#change_status?" do
    subject(:policy) { described_class.new(user, Initiative.new(status: :idea)) }

    context "when user is not authenticated" do
      let(:user) { nil }

      it { expect(policy.change_status?).to be false }
    end

    context "when user is a sympathizer" do
      let(:user) { build_user(:sympathizer) }

      it { expect(policy.change_status?).to be false }
    end

    context "when user is a militant" do
      let(:user) { build_user(:militant) }

      it { expect(policy.change_status?).to be false }
    end

    context "when user is a moderator" do
      let(:user) { build_user(:moderator) }

      it { expect(policy.change_status?).to be false }
    end

    context "when user is a board member" do
      let(:user) { build_user(:board_member) }

      it { expect(policy.change_status?).to be true }
    end

    context "when user is a technical admin" do
      let(:user) { build_user(:technical_admin) }

      it { expect(policy.change_status?).to be true }
    end
  end
end
