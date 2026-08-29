require "rails_helper"

RSpec.describe Topic, type: :model do
  describe "validations" do
    it "requires a unique slug" do
      Topic.create!(
        name: "Ideas",
        slug: "ideas",
        description: "Propuestas",
        position: 1
      )

      duplicate = Topic.new(
        name: "Otra categoría",
        slug: "ideas",
        description: "Duplicado",
        position: 2
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include("has already been taken")
    end
  end
end
