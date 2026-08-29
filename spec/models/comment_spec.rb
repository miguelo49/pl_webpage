require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:author) do
    User.create!(
      email: "comment-author@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end
  let(:thread) do
    ForumThread.create!(
      title: "Hilo de prueba",
      body: "Contenido",
      topic: topic,
      user: author
    )
  end

  describe "nested replies" do
    let!(:top_level_comment) do
      described_class.create!(
        body: "Comentario principal",
        user: author,
        commentable: thread
      )
    end

    it "allows a reply to a top-level comment" do
      reply = described_class.new(
        body: "Respuesta",
        user: author,
        commentable: thread,
        parent: top_level_comment
      )

      expect(reply).to be_valid
      expect { reply.save! }.not_to raise_error
      expect(reply.parent).to eq(top_level_comment)
    end

    it "does not allow replying to a reply" do
      reply = described_class.create!(
        body: "Respuesta",
        user: author,
        commentable: thread,
        parent: top_level_comment
      )

      nested_reply = described_class.new(
        body: "Respuesta anidada",
        user: author,
        commentable: thread,
        parent: reply
      )

      expect(nested_reply).not_to be_valid
      expect(nested_reply.errors[:parent]).to include("cannot be a reply")
    end

    it "requires the parent to belong to the same commentable" do
      other_thread = ForumThread.create!(
        title: "Otro hilo",
        body: "Otro contenido",
        topic: topic,
        user: author
      )

      reply = described_class.new(
        body: "Respuesta inválida",
        user: author,
        commentable: other_thread,
        parent: top_level_comment
      )

      expect(reply).not_to be_valid
      expect(reply.errors[:parent]).to include("must belong to the same commentable")
    end
  end
end
