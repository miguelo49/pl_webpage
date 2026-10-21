require "rails_helper"

RSpec.describe "User registration", type: :request do
  around do |example|
    original = Rails.application.config.skip_user_rut_validation
    Rails.application.config.skip_user_rut_validation = false
    example.run
    Rails.application.config.skip_user_rut_validation = original
  end

  it "creates a sympathizer with email, rut and password" do
    email = "nuevo-#{SecureRandom.hex(4)}@example.com"
    rut = unique_valid_rut

    post user_registration_path, params: {
      user: {
        email: email,
        rut: rut,
        password: "password123",
        password_confirmation: "password123",
        role: "technical_admin"
      }
    }

    user = User.find_by!(email: email)
    expect(user.role).to eq("sympathizer")
    expect(user.rut).to eq(User.normalize(rut))
  end
end
