require "rails_helper"

RSpec.describe Region, type: :model do
  describe "associations" do
    it "has many communes" do
      region = Region.create!(name: "Región de Valparaíso")
      commune = Commune.create!(name: "Valparaíso", region: region)

      expect(region.communes).to include(commune)
    end
  end
end
