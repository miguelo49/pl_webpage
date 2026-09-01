require "rails_helper"

RSpec.describe Commune, type: :model do
  describe "associations" do
    it "belongs to a region" do
      region = Region.create!(name: "Región de Valparaíso")
      commune = Commune.create!(name: "Valparaíso", region: region)

      expect(commune.region).to eq(region)
      expect(commune).to respond_to(:region)
    end
  end

  describe "scopes" do
    let(:region) { Region.create!(name: "Región de Valparaíso") }
    let(:other_region) { Region.create!(name: "Región Metropolitana") }

    it "returns communes from the territory region ordered by name" do
      valparaiso = Commune.create!(name: "Valparaíso", region: region)
      vina = Commune.create!(name: "Viña del Mar", region: region)
      Commune.create!(name: "Santiago", region: other_region)

      expect(Commune.in_territory).to eq([ valparaiso, vina ])
    end
  end

  describe "validations" do
    let(:region) { Region.create!(name: "Región de Valparaíso") }

    it "requires a name" do
      commune = Commune.new(region: region)
      expect(commune).not_to be_valid
      expect(commune.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name within the same region" do
      Commune.create!(name: "Viña del Mar", region: region)

      duplicate = Commune.new(name: "Viña del Mar", region: region)
      expect(duplicate).not_to be_valid
    end
  end
end
