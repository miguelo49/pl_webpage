require "rails_helper"

RSpec.describe TrainingMaterialPolicy, type: :policy do
  subject(:policy) { described_class.new(user, TrainingMaterial.new) }

  def build_user(role)
    User.new(
      role: role,
      email: "#{role}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  describe "#show?" do
    let(:material) { TrainingMaterial.new(sympathizer_visible: true) }

    subject(:policy) { described_class.new(user, material) }

    context "when user is a sympathizer and material is visible to sympathizers" do
      let(:user) { build_user(:sympathizer) }

      it { expect(policy.show?).to be true }
    end

    context "when user is a sympathizer and material is militant-only" do
      let(:user) { build_user(:sympathizer) }
      let(:material) { TrainingMaterial.new(sympathizer_visible: false) }

      it { expect(policy.show?).to be false }
    end

    context "when user is a militant and material is militant-only" do
      let(:user) { build_user(:militant) }
      let(:material) { TrainingMaterial.new(sympathizer_visible: false) }

      it { expect(policy.show?).to be true }
    end
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

      it { expect(policy.create?).to be false }
    end

    context "when user is a moderator" do
      let(:user) { build_user(:moderator) }

      it { expect(policy.create?).to be false }
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
