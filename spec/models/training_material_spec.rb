require "rails_helper"

RSpec.describe TrainingMaterial, type: :model do
  let(:category) { TrainingCategory.create!(name: "Ideología") }

  it "stores tags as an array" do
    material = described_class.create!(
      title: "Manual de formación",
      description: "Material introductorio",
      author: "Equipo editorial",
      date: Date.current,
      training_category: category,
      tags: [ "marxismo", "historia" ]
    )

    expect(material.reload.tags).to eq([ "marxismo", "historia" ])
  end
end
