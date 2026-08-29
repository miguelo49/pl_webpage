require "rails_helper"

RSpec.describe "Onboarding flow", type: :request do
  let(:password) { "password123" }

  def register_user(email: "newuser@example.com", first_name: "María", last_name: "García")
    post user_registration_path, params: {
      user: {
        email: email,
        password: password,
        password_confirmation: password,
        first_name: first_name,
        last_name: last_name
      }
    }
  end

  def accept_terms
    patch onboarding_path, params: { terms_accepted: "1" }
  end

  describe "full flow after registration" do
    it "redirects to onboarding and completes to home" do
      register_user
      expect(response).to redirect_to(root_path)

      follow_redirect!
      expect(response).to redirect_to(onboarding_path)

      follow_redirect!
      expect(response.body).to include("Términos básicos")

      accept_terms
      expect(response).to redirect_to(root_path)

      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(User.find_by(email: "newuser@example.com").complete?).to be(true)
    end
  end

  describe "profile step when names are missing" do
    it "collects names via turbo frame then terms, then home" do
      user = User.create!(
        email: "incomplete@example.com",
        password: password,
        first_name: "Temp",
        last_name: "User"
      )
      user.update_columns(first_name: "", last_name: "")
      sign_in user

      get onboarding_path
      expect(response.body).to include("Tu perfil")

      patch onboarding_path,
            params: { user: { first_name: "Laura", last_name: "Martínez" } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("Términos básicos")
      expect(user.reload.profile_complete?).to be(true)

      accept_terms
      expect(response).to redirect_to(root_path)
      expect(user.reload.complete?).to be(true)
    end
  end

  describe "when onboarding is already complete" do
    it "skips onboarding and allows home access" do
      user = User.create!(
        email: "complete@example.com",
        password: password,
        first_name: "Ana",
        last_name: "López",
        terms_accepted_at: Time.current
      )
      sign_in user

      get onboarding_path
      expect(response).to redirect_to(root_path)

      get root_path
      expect(response).to have_http_status(:ok)
      expect(response).not_to redirect_to(onboarding_path)
    end
  end
end
