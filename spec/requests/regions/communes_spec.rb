require "rails_helper"

RSpec.describe "Regions::Communes", type: :request do
  let(:password) { "password123" }
  let!(:user) do
    User.create!(
      email: "communes@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end
  let!(:region) { Region.create!(name: "Región de Valparaíso") }
  let!(:valparaiso) { Commune.create!(name: "Valparaíso", region: region) }
  let!(:vina) { Commune.create!(name: "Viña del Mar", region: region) }
  let!(:other_region) { Region.create!(name: "Región Metropolitana") }
  let!(:santiago) { Commune.create!(name: "Santiago", region: other_region) }

  before { sign_in user }

  describe "GET /regions/:region_id/communes" do
    it "returns communes for the selected region as JSON" do
      get region_communes_path(region), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")

      json = JSON.parse(response.body)
      expect(json.pluck("name")).to contain_exactly("Valparaíso", "Viña del Mar")
      expect(json.pluck("id")).to contain_exactly(valparaiso.id, vina.id)
    end

    it "does not include communes from other regions" do
      get region_communes_path(region), as: :json

      json = JSON.parse(response.body)
      expect(json.pluck("name")).not_to include("Santiago")
    end

    it "requires authentication" do
      sign_out user

      get region_communes_path(region), as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found for an unknown region" do
      get region_communes_path(region_id: 0), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
