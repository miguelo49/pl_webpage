require "rails_helper"

RSpec.describe "Initiatives", type: :request do
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

  def create_initiative(author:)
    region = Region.find_or_create_by!(name: "Región de Valparaíso")
    commune = Commune.find_or_create_by!(name: "Valparaíso", region: region)

    Initiative.create!(
      title: "Mejor transporte público",
      description: "Propuesta para mejorar la movilidad comunal.",
      problem: "Los buses están saturados y con poca frecuencia.",
      proposal: "Ampliar recorridos y aumentar la frecuencia en hora punta.",
      category: "transport",
      user: author,
      commune: commune
    )
  end

  describe "POST /initiatives/:id/react" do
    it "toggles support for an initiative via turbo stream" do
      author = create_user(role: :militant)
      supporter = create_user(role: :sympathizer)
      initiative = create_initiative(author: author)

      sign_in supporter

      expect {
        post react_initiative_path(initiative),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Reaction, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include(">1<")
      expect(response.body).to include("Apoyar")

      expect {
        post react_initiative_path(initiative),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Reaction, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(">0<")
    end
  end

  describe "POST /initiatives/:id/attach_documents" do
    it "attaches a document to an initiative" do
      author = create_user(role: :militant)
      uploader = create_user(role: :militant, email: "uploader-#{SecureRandom.hex(4)}@example.com")
      initiative = create_initiative(author: author)

      sign_in uploader

      expect {
        post attach_documents_initiative_path(initiative), params: {
          initiative: {
            documents: [ fixture_file_upload("sample.pdf", "application/pdf") ]
          }
        }
      }.to change { initiative.reload.documents.count }.by(1)

      expect(response).to redirect_to(initiative_path(initiative))
      expect(initiative.documents.first.filename.to_s).to eq("sample.pdf")
    end
  end
end
