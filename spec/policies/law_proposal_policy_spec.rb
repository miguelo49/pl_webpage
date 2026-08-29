require "rails_helper"

RSpec.describe LawProposalPolicy, type: :policy do
  subject(:policy) { described_class.new(user, LawProposal.new) }

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

    context "when user is a board member" do
      let(:user) { build_user(:board_member) }

      it { expect(policy.create?).to be true }
    end

    context "when user is a technical admin" do
      let(:user) { build_user(:technical_admin) }

      it { expect(policy.create?).to be true }
    end
  end
end
