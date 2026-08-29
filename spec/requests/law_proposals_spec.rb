require "rails_helper"

RSpec.describe "Law proposals", type: :request do
  let(:password) { "password123" }

  def create_user(role:, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      region = Region.find_or_create_by!(name: "Región de Valparaíso")
      attrs[:residence_commune] = Commune.find_or_create_by!(name: "Valparaíso", region: region)
    end

    User.create!(attrs)
  end

  def create_law_proposal(author:)
    region = Region.find_or_create_by!(name: "Región de Valparaíso")
    commune = Commune.find_or_create_by!(name: "Valparaíso", region: region)

    LawProposal.create!(
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

  describe "GET /law_proposals/:id" do
    it "shows the current text by default and navigates historical versions without losing it" do
      author = create_user(role: :militant)
      viewer = create_user(role: :sympathizer)
      law_proposal = create_law_proposal(author: author)
      original_text = law_proposal.current_text
      revised_text = "#{original_text}\nArtículo 2. Definiciones."

      law_proposal.text_edited_by = author
      law_proposal.update!(current_text: revised_text)
      version = law_proposal.versions.last

      sign_in viewer

      get law_proposal_path(law_proposal)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(revised_text)
      expect(response.body).to include("Texto vigente actual")

      get law_proposal_path(law_proposal, version_id: version.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(original_text)
      expect(response.body).to include("solo lectura")
      expect(response.body).to include(revised_text)
      expect(response.body).to include("Ver texto actual")

      get law_proposal_path(law_proposal)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(revised_text)
    end
  end

  describe "GET /law_proposals" do
    it "filters law proposals by status" do
      author = create_user(role: :militant)
      viewer = create_user(role: :sympathizer)
      visible = create_law_proposal(author: author)
      hidden = create_law_proposal(author: author)
      hidden.update!(status: :discussion, name: "Propuesta en discusión")

      sign_in viewer
      get law_proposals_path, params: { status: "idea" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(visible.name)
      expect(response.body).not_to include(hidden.name)
    end
  end
end
