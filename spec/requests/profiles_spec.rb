require "rails_helper"

RSpec.describe "Profile", type: :request do
  let(:password) { "password123" }

  let!(:user) do
    User.create!(
      email: "profile@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end

  before { sign_in user }

  describe "GET /profile" do
    it "shows the profile page" do
      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mi perfil")
      expect(response.body).to include("Ana")
      expect(response.body).to include("López")
    end

    it "requires authentication" do
      sign_out user

      get profile_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PATCH /profile" do
    it "updates names via turbo stream without a full page reload" do
      patch profile_path,
            params: { user: { first_name: "María", last_name: "García" } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("María")
      expect(response.body).to include("García")
      expect(user.reload.full_name).to eq("María García")
    end

    it "updates avatar via turbo stream" do
      file = fixture_file_upload("avatar.png", "image/png")

      patch profile_path,
            params: { user: { avatar: file } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(user.reload.avatar).to be_attached
      expect(response.body).to include("turbo-stream")
    end

    it "returns unprocessable entity for invalid data" do
      patch profile_path, params: { user: { first_name: "", last_name: "García" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Mi perfil")
      expect(user.reload.first_name).to eq("Ana")
    end

    it "rejects invalid avatar content type" do
      file = Tempfile.new([ "invalid", ".txt" ])
      file.write("not an image")
      file.rewind

      uploaded = Rack::Test::UploadedFile.new(file.path, "text/plain", original_filename: "invalid.txt")

      patch profile_path, params: { user: { avatar: uploaded } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.avatar).not_to be_attached
    end
  end
end
