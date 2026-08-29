require "rails_helper"

RSpec.describe Report, type: :model do
  let(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  let(:reporter) do
    User.create!(
      email: "reporter@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      role: :sympathizer,
      terms_accepted_at: Time.current
    )
  end

  let(:author) do
    User.create!(
      email: "thread-author@example.com",
      password: "password123",
      first_name: "Carlos",
      last_name: "Rivas",
      role: :board_member,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  let(:thread) do
    ForumThread.create!(
      title: "Hilo reportable",
      body: "Contenido del hilo",
      topic: topic,
      user: author,
      status: :approved
    )
  end

  describe "reporting moderable content" do
    it "creates a report for a forum thread" do
      expect {
        described_class.create!(
          user: reporter,
          reportable: thread,
          reason: "Contenido ofensivo"
        )
      }.to change(described_class, :count).by(1)

      report = described_class.last
      expect(report.user).to eq(reporter)
      expect(report.reportable).to eq(thread)
      expect(report.reason).to eq("Contenido ofensivo")
    end

    it "creates a report for a comment" do
      comment = Comment.create!(
        body: "Comentario reportable",
        user: author,
        commentable: thread,
        status: :approved
      )

      expect {
        described_class.create!(
          user: reporter,
          reportable: comment,
          reason: "Spam"
        )
      }.to change(described_class, :count).by(1)

      expect(described_class.last.reportable).to eq(comment)
    end

    it "creates a report for an initiative" do
      initiative = Initiative.create!(
        title: "Iniciativa reportable",
        description: "Descripción",
        problem: "Problema",
        proposal: "Propuesta",
        category: "transport",
        user: author,
        commune: commune
      )

      expect {
        described_class.create!(
          user: reporter,
          reportable: initiative,
          reason: "Información incorrecta"
        )
      }.to change(described_class, :count).by(1)

      expect(described_class.last.reportable).to eq(initiative)
    end

    it "requires a reason" do
      report = described_class.new(user: reporter, reportable: thread)

      expect(report).not_to be_valid
      expect(report.errors[:reason]).to include("can't be blank")
    end
  end
end
