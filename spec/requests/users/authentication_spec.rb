require "rails_helper"

RSpec.describe "User registration", type: :request do
  describe "POST /users" do
    it "creates a user with default simpatizante role" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "new@example.com",
            password: "password123",
            password_confirmation: "password123",
            nombre: "María",
            apellido: "García"
          }
        }
      }.to change(User, :count).by(1)

      user = User.find_by(email: "new@example.com")
      expect(user).to be_present
      expect(user.nombre).to eq("María")
      expect(user.apellido).to eq("García")
      expect(user.role).to eq("simpatizante")
      expect(user.activo).to be(true)
      expect(response).to redirect_to(root_path)
    end

    it "rejects registration without nombre" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "invalid@example.com",
            password: "password123",
            password_confirmation: "password123",
            apellido: "García"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

RSpec.describe "User login", type: :request do
  let!(:user) do
    User.create!(
      email: "login@example.com",
      password: "password123",
      nombre: "Pedro",
      apellido: "Soto"
    )
  end

  describe "POST /users/sign_in" do
    it "signs in the user" do
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(controller.current_user).to eq(user)
    end
  end

  describe "DELETE /users/sign_out" do
    it "signs out the user" do
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(controller.current_user).to be_nil
    end
  end
end
