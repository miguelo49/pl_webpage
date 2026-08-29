require "rails_helper"

RSpec.describe Reaction, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:author) do
    User.create!(
      email: "reaction-author@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end
  let(:reactor) do
    User.create!(
      email: "reactor@example.com",
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
    it "allows only one reaction per user and reactable" do
      described_class.create!(user: reactor, reactable: thread)

      duplicate = described_class.new(user: reactor, reactable: thread)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows the same user to react on different content" do
      comment = Comment.create!(
        body: "Comentario",
        user: author,
        commentable: thread,
        status: :approved
      )

      expect {
        described_class.create!(user: reactor, reactable: thread)
        described_class.create!(user: reactor, reactable: comment)
      }.to change(described_class, :count).by(2)
    end
  end
end
