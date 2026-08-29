require "rails_helper"

RSpec.describe ModerationLog, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  def create_user(role:, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }
    attrs[:residence_commune] = commune if User.new(role: role).militant_or_above?

    User.create!(attrs)
  end

  let(:author) { create_user(role: :sympathizer) }
  let(:moderator) { create_user(role: :moderator) }

  let(:thread) do
    ForumThread.create!(
      title: "Hilo pendiente",
      body: "Contenido del hilo",
      topic: topic,
      user: author,
      status: :pending
    )
  end

  describe "moderation audit trail" do
    it "records an approve action when a moderator approves a thread" do
      thread.moderated_by = moderator

      expect {
        thread.update!(status: :approved)
      }.to change(described_class, :count).by(1)

      log = described_class.last
      expect(log.moderator).to eq(moderator)
      expect(log.moderatable).to eq(thread)
      expect(log.action).to eq("approve")
      expect(log.rejection_reason).to be_nil
    end

    it "records a reject action with rejection reason when a moderator rejects a comment" do
      comment = Comment.create!(
        body: "Comentario pendiente",
        user: author,
        commentable: thread,
        status: :pending
      )
      comment.moderated_by = moderator
      comment.moderation_rejection_reason = "Fuera de tema"

      expect {
        comment.update!(status: :rejected)
      }.to change(described_class, :count).by(1)

      log = described_class.last
      expect(log.moderator).to eq(moderator)
      expect(log.moderatable).to eq(comment)
      expect(log.action).to eq("reject")
      expect(log.rejection_reason).to eq("Fuera de tema")
    end

    it "records moderation when a board member changes initiative status" do
      board_member = create_user(role: :board_member)
      initiative = Initiative.create!(
        title: "Iniciativa en revisión",
        description: "Descripción",
        problem: "Problema",
        proposal: "Propuesta",
        category: "transport",
        user: author,
        commune: commune,
        status: :in_review
      )
      initiative.status_changed_by = board_member
      initiative.moderated_by = board_member

      expect {
        initiative.update!(status: :approved)
      }.to change(described_class, :count).by(1)

      log = described_class.last
      expect(log.moderator).to eq(board_member)
      expect(log.moderatable).to eq(initiative)
      expect(log.action).to eq("approve")
    end

    it "does not record moderation when status changes without a moderator actor" do
      expect {
        thread.update!(status: :approved)
      }.not_to change(described_class, :count)
    end

    it "does not record moderation when a non-moderator attempts to set moderated_by" do
      thread.moderated_by = author

      expect {
        thread.update!(status: :approved)
      }.not_to change(described_class, :count)
    end
  end
end
