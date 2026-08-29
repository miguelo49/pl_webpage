require "rails_helper"

RSpec.describe Bookmark, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:author) do
    User.create!(
      email: "bookmark-author@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end
  let(:saver) do
    User.create!(
      email: "saver@example.com",
      password: "password123",
      first_name: "Luis",
      last_name: "Pérez",
      terms_accepted_at: Time.current
    )
  end
  let(:thread) do
    ForumThread.create!(
      title: "Hilo de prueba",
      body: "Contenido",
      topic: topic,
      user: author,
      status: :approved
    )
  end

  describe "uniqueness" do
    it "allows only one bookmark per user and bookmarkable" do
      described_class.create!(user: saver, bookmarkable: thread)

      duplicate = described_class.new(user: saver, bookmarkable: thread)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
  end
end
