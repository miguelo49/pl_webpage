require "rails_helper"

RSpec.describe "User registration", type: :request do
  it "creates a sympathizer account even if a higher role is submitted" do
    email = "nuevo-#{SecureRandom.hex(4)}@example.com"

    post user_registration_path, params: {
      user: {
        email: email,
        password: "password123",
        password_confirmation: "password123",
        first_name: "Nuevo",
        last_name: "Usuario",
        role: "technical_admin"
      }
    }

    user = User.find_by!(email: email)
    expect(user.role).to eq("sympathizer")
  end
end
