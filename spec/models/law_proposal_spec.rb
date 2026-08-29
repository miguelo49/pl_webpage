require "rails_helper"

RSpec.describe LawProposal, type: :model do
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  let(:author) do
    User.create!(
      email: "law-proposal-author@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      role: :militant,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  let(:editor) do
    User.create!(
      email: "law-proposal-editor@example.com",
      password: "password123",
      first_name: "Carlos",
      last_name: "Rivas",
      role: :militant,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  def build_law_proposal
    described_class.new(
      name: "Ley de movilidad sustentable",
      problem: "El transporte público no cubre las necesidades actuales.",
      rationale: "Se requiere un marco normativo actualizado.",
      objective: "Regular la movilidad comunal con enfoque ambiental.",
      current_text: "Artículo 1. Objeto de la ley.",
      category: "transport",
      user: author,
      commune: commune
    )
  end

  describe "text version history" do
    it "creates a version with the previous text when current_text is updated" do
      law_proposal = build_law_proposal
      law_proposal.save!
      law_proposal.text_edited_by = editor

      expect {
        law_proposal.update!(current_text: "Artículo 1. Objeto de la ley.\nArtículo 2. Definiciones.")
      }.to change(LawProposalVersion, :count).by(1)

      version = law_proposal.versions.last
      expect(version.text).to eq("Artículo 1. Objeto de la ley.")
      expect(version.user).to eq(editor)
      expect(law_proposal.current_text).to eq("Artículo 1. Objeto de la ley.\nArtículo 2. Definiciones.")
    end

    it "does not create a version when current_text is unchanged" do
      law_proposal = build_law_proposal
      law_proposal.save!

      expect {
        law_proposal.update!(name: "Nombre actualizado")
      }.not_to change(LawProposalVersion, :count)
    end

    it "stores multiple recoverable versions across successive edits" do
      law_proposal = build_law_proposal
      law_proposal.save!
      original_text = law_proposal.current_text
      first_revision = "#{original_text}\nArtículo 2. Definiciones."
      second_revision = "#{first_revision}\nArtículo 3. Obligaciones."

      law_proposal.text_edited_by = author
      law_proposal.update!(current_text: first_revision)

      law_proposal.text_edited_by = editor
      law_proposal.update!(current_text: second_revision)

      expect(law_proposal.versions.order(:created_at).pluck(:text)).to eq([ original_text, first_revision ])
    end
  end
end
