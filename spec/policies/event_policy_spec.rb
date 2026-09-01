require "rails_helper"

RSpec.describe EventPolicy, type: :policy do
  subject(:policy) { described_class.new(user, event) }

  let(:event) { Event.new(organizer: organizer, status: event_status) }
  let(:organizer) { build_user(:militant) }
  let(:event_status) { :approved }

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

  describe "#show?" do
    context "when event is approved" do
      let(:event_status) { :approved }
      let(:user) { build_user(:sympathizer) }

      it { expect(policy.show?).to be true }
    end

    context "when event is pending" do
      let(:event_status) { :pending }

      context "and user is the organizer" do
        let(:user) { organizer }

        it { expect(policy.show?).to be true }
      end

      context "and user is a sympathizer" do
        let(:user) { build_user(:sympathizer) }

        it { expect(policy.show?).to be false }
      end

      context "and user is a moderator" do
        let(:user) { build_user(:moderator) }

        it { expect(policy.show?).to be true }
      end
    end
  end

  describe "Scope" do
    let(:region) { Region.create!(name: "Región de Valparaíso") }
    let(:commune) { Commune.create!(name: "Valparaíso", region: region) }
    let(:organizer_user) do
      User.create!(
        email: "organizer@example.com",
        password: "password123",
        first_name: "Org",
        last_name: "User",
        role: :militant,
        terms_accepted_at: Time.current,
        residence_commune: commune
      )
    end
    let!(:approved_event) do
      Event.create!(
        title: "Evento aprobado",
        description: "Descripción",
        event_type: :meeting,
        start_at: 2.days.from_now,
        organizer: organizer_user,
        status: :approved
      )
    end
    let!(:pending_event) do
      Event.create!(
        title: "Evento pendiente",
        description: "Descripción",
        event_type: :talk,
        start_at: 3.days.from_now,
        organizer: organizer_user,
        status: :pending
      )
    end

    it "shows only approved events to sympathizers" do
      viewer = build_user(:sympathizer)
      scope = described_class::Scope.new(viewer, Event.all).resolve

      expect(scope).to include(approved_event)
      expect(scope).not_to include(pending_event)
    end

    it "shows pending events to their organizer" do
      scope = described_class::Scope.new(organizer_user, Event.all).resolve

      expect(scope).to include(approved_event, pending_event)
    end
  end
end
