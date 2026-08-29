require "rails_helper"

RSpec.describe "Training materials library", type: :request do
  let(:password) { "password123" }

  def create_user(role: :sympathizer, email: nil)
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

  def create_material(category:, title:, tags: [], attach_pdf: false)
    material = TrainingMaterial.create!(
      title: title,
      description: "Descripción de #{title}",
      author: "Equipo editorial",
      date: Date.current,
      training_category: category,
      tags: tags
    )

    if attach_pdf
      material.pdf.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/sample.pdf")),
        filename: "#{title.parameterize}.pdf",
        content_type: "application/pdf"
      )
    end

    material
  end

  let!(:ideology_category) { TrainingCategory.create!(name: "Ideología") }
  let!(:organization_category) { TrainingCategory.create!(name: "Organización") }

  describe "GET /training_materials" do
    it "filters materials by title search" do
      user = create_user(role: :sympathizer)
      create_material(category: ideology_category, title: "Manual de estatutos", tags: [ "normativa" ])
      create_material(category: organization_category, title: "Guía territorial", tags: [ "comunas" ])

      sign_in user
      get training_materials_path, params: { q: "estatutos" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Manual de estatutos")
      expect(response.body).not_to include("Guía territorial")
    end

    it "filters materials by tag search" do
      user = create_user(role: :sympathizer)
      create_material(category: ideology_category, title: "Introducción", tags: [ "marxismo" ])
      create_material(category: organization_category, title: "Manual territorial", tags: [ "comunas" ])

      sign_in user
      get training_materials_path, params: { q: "marxismo" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Introducción")
      expect(response.body).not_to include("Manual territorial")
    end
  end

  describe "POST /training_materials/:id/read_mark" do
    it "marks a material as read and reflects it visually" do
      user = create_user(role: :sympathizer)
      material = create_material(category: ideology_category, title: "Material leído", tags: [ "lectura" ])

      sign_in user

      post read_mark_training_material_path(material),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Leído")
      expect(ReadMark.exists?(user: user, training_material: material)).to be(true)

      get training_materials_path

      expect(response.body).to include("Leído")
      expect(response.body).not_to include("Marcar como leído")
    end
  end

  describe "GET /training_materials/:id/download" do
    it "responds with the attached PDF file" do
      user = create_user(role: :sympathizer)
      material = create_material(category: ideology_category, title: "Manual descargable", attach_pdf: true)

      sign_in user
      get download_training_material_path(material)

      expect(response).to have_http_status(:found)
      expect(response.location).to include("disposition=attachment")

      follow_redirect!

      if response.redirect?
        follow_redirect!
      end

      expect(response.content_type).to eq("application/pdf")
      expect(response.body).to start_with("%PDF")
    end
  end
end
