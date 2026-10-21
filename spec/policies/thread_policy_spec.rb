require "rails_helper"

RSpec.describe ThreadPolicy, type: :policy do
  let(:topic) { Topic.new(id: 1, name: "Ideas", slug: "ideas") }

  def build_user(role)
    User.new(
      role: role,
      email: "#{role}@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  def build_thread(sympathizer_visible: true, status: :approved)
    ForumThread.new(
      title: "Hilo",
      body: "Cuerpo",
      topic: topic,
      user: build_user(:sympathizer),
      status: status,
      sympathizer_visible: sympathizer_visible
    )
  end

  describe "#show?" do
    context "when user is a sympathizer and thread is militant-only" do
      let(:user) { build_user(:sympathizer) }
      let(:thread) { build_thread(sympathizer_visible: false) }

      it { expect(described_class.new(user, thread).show?).to be false }
    end

    context "when user is a militant and thread is militant-only" do
      let(:user) { build_user(:militant) }
      let(:thread) { build_thread(sympathizer_visible: false) }

      it { expect(described_class.new(user, thread).show?).to be true }
    end
  end

  describe "Scope" do
    let!(:topic_record) { Topic.create!(name: "Ideas", slug: "ideas-scope", description: "x", position: 1) }
    let!(:author) do
      User.create!(
        email: "author-scope@example.com",
        password: "password123",
        first_name: "A",
        last_name: "B",
        role: :sympathizer,
        terms_accepted_at: Time.current
      )
    end

    before do
      ForumThread.create!(
        title: "Público",
        body: "x",
        topic: topic_record,
        user: author,
        status: :approved,
        sympathizer_visible: true
      )
      ForumThread.create!(
        title: "Militantes",
        body: "x",
        topic: topic_record,
        user: author,
        status: :approved,
        sympathizer_visible: false
      )
    end

    it "returns only sympathizer-visible approved threads for sympathizers" do
      user = build_user(:sympathizer)
      scope = described_class::Scope.new(user, ForumThread.all).resolve

      expect(scope.pluck(:title)).to contain_exactly("Público")
    end

    it "returns all approved threads for militants" do
      region = Region.find_or_create_by!(name: "Región de Valparaíso")
      commune = Commune.find_or_create_by!(name: "Valparaíso", region: region)
      user = User.create!(
        email: "militant-scope@example.com",
        password: "password123",
        first_name: "M",
        last_name: "L",
        role: :militant,
        terms_accepted_at: Time.current,
        residence_commune: commune
      )
      scope = described_class::Scope.new(user, ForumThread.all).resolve

      expect(scope.pluck(:title)).to contain_exactly("Público", "Militantes")
    end
  end
end
