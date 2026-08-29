require "rails_helper"

RSpec.describe ForumThread, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:region) { Region.create!(name: "Región de Valparaíso") }
  let(:commune) { Commune.create!(name: "Valparaíso", region: region) }

  def create_author(role)
    attrs = {
      email: "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }
    attrs[:residence_commune] = commune if User.new(role: role).militant_or_above?

    User.create!(attrs)
  end

  def build_thread(author)
    described_class.new(
      title: "Título de prueba",
      body: "Contenido del hilo",
      topic: topic,
      user: author
    )
  end

  describe "initial status by author role" do
    it "sets pending for a sympathizer author" do
      thread = build_thread(create_author(:sympathizer))

      thread.valid?

      expect(thread.status).to eq("pending")
      expect(thread.publicly_visible?).to be(false)
    end

    it "sets pending for a militant author" do
      thread = build_thread(create_author(:militant))

      thread.valid?

      expect(thread.status).to eq("pending")
    end

    it "sets approved for a board_member author" do
      thread = build_thread(create_author(:board_member))

      thread.valid?

      expect(thread.status).to eq("approved")
      expect(thread.publicly_visible?).to be(true)
    end

    it "sets approved for a moderator author" do
      thread = build_thread(create_author(:moderator))

      thread.valid?

      expect(thread.status).to eq("approved")
      expect(thread.publicly_visible?).to be(true)
    end
  end
end
