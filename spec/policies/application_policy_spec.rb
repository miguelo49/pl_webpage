require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  subject(:policy) { test_policy_class.new(user, :record) }

  let(:test_policy_class) do
    Class.new(described_class) do
      def militant_or_above?
        super
      end

      def board_or_above?
        super
      end

      def moderator?
        super
      end

      def admin?
        super
      end
    end
  end

  def build_user(role)
    User.new(
      role: role,
      email: "#{role}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  context "when user is a sympathizer" do
    let(:user) { build_user(:sympathizer) }

    it { expect(policy.militant_or_above?).to be false }
    it { expect(policy.board_or_above?).to be false }
    it { expect(policy.moderator?).to be false }
    it { expect(policy.admin?).to be false }
  end

  context "when user is a militant" do
    let(:user) { build_user(:militant) }

    it { expect(policy.militant_or_above?).to be true }
    it { expect(policy.board_or_above?).to be false }
    it { expect(policy.moderator?).to be false }
    it { expect(policy.admin?).to be false }
  end

  context "when user is a board member" do
    let(:user) { build_user(:board_member) }

    it { expect(policy.militant_or_above?).to be true }
    it { expect(policy.board_or_above?).to be true }
    it { expect(policy.moderator?).to be false }
    it { expect(policy.admin?).to be false }
  end

  context "when user is a moderator" do
    let(:user) { build_user(:moderator) }

    it { expect(policy.militant_or_above?).to be true }
    it { expect(policy.board_or_above?).to be true }
    it { expect(policy.moderator?).to be true }
    it { expect(policy.admin?).to be false }
  end

  context "when user is a technical admin" do
    let(:user) { build_user(:technical_admin) }

    it { expect(policy.militant_or_above?).to be true }
    it { expect(policy.board_or_above?).to be true }
    it { expect(policy.moderator?).to be true }
    it { expect(policy.admin?).to be true }
  end

  context "when user is not authenticated" do
    let(:user) { nil }

    it { expect(policy.militant_or_above?).to be false }
    it { expect(policy.board_or_above?).to be false }
    it { expect(policy.moderator?).to be false }
    it { expect(policy.admin?).to be false }
  end
end
