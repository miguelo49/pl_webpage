require "rails_helper"

RSpec.describe ReadMark, type: :model do
  let(:category) { TrainingCategory.create!(name: "Ideología") }
  let(:user) do
    User.create!(
      email: "read-mark-user@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end
  let(:training_material) do
    TrainingMaterial.create!(
      title: "Manual",
      description: "Descripción",
      author: "Autor",
      date: Date.current,
      training_category: category,
      tags: [ "formación" ]
    )
  end

  it "allows only one read mark per user and material" do
    described_class.create!(user: user, training_material: training_material)

    duplicate = described_class.new(user: user, training_material: training_material)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:user_id]).to include("has already been taken")
  end
end
