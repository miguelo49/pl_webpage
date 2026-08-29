require "rails_helper"

RSpec.describe TrainingCategory, type: :model do
  it "requires a unique name" do
    described_class.create!(name: "Formación básica")

    duplicate = described_class.new(name: "Formación básica")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("has already been taken")
  end
end
