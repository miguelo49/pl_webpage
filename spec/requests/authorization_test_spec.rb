require "rails_helper"

RSpec.describe "Authorization test access", type: :request do
  let(:password) { "password123" }

  def create_user(role)
    User.create!(
      email: "#{role}@example.com",
      password: password,
      first_name: "Test",
      last_name: "User",
      role: role
    )
  end

  describe "GET /authorization_test" do
    it "redirects sympathizers with a flash alert" do
      user = create_user(:sympathizer)
      user.update!(terms_accepted_at: Time.current)
      sign_in user

      get authorization_test_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("No tienes permiso para realizar esta acción.")
    end

    it "allows militants" do
      user = create_user(:militant)
      user.update!(terms_accepted_at: Time.current)
      sign_in user

      get authorization_test_path

      expect(response).to have_http_status(:ok)
    end
  end
end
