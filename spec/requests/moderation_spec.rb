require "rails_helper"

RSpec.describe "Moderation panel", type: :request do
  let(:password) { "password123" }
  let!(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  def create_user(role:, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      attrs[:residence_commune] = commune
    end

    User.create!(attrs)
  end

  def create_pending_thread(author:)
    ForumThread.create!(
      title: "Hilo pendiente de moderación",
      body: "Contenido del hilo pendiente",
      topic: topic,
      user: author,
      status: :pending
    )
  end

  describe "GET /moderation" do
    it "denies access to a sympathizer" do
      user = create_user(role: :sympathizer)
      sign_in user

      get moderation_root_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("No tienes permiso para realizar esta acción.")
    end

    it "denies access to a militant" do
      user = create_user(role: :militant)
      sign_in user

      get moderation_root_path

      expect(response).to redirect_to(root_path)
    end

    it "allows a moderator to view the queue" do
      author = create_user(role: :sympathizer)
      moderator = create_user(role: :moderator)
      thread = create_pending_thread(author: author)

      sign_in moderator
      get moderation_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(thread.title)
    end
  end

  describe "PATCH /moderation/items/:type/:id" do
    it "resolves a pending item via turbo stream and removes it from the queue" do
      author = create_user(role: :sympathizer)
      moderator = create_user(role: :moderator)
      thread = create_pending_thread(author: author)

      sign_in moderator

      expect {
        patch moderation_item_path(type: "forum_thread", id: thread.id),
              params: { decision: "approve" },
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(ModerationLog, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("action=\"remove\"")
      expect(thread.reload).to be_approved

      get moderation_root_path

      expect(response.body).not_to include(thread.title)
    end

    it "requires a rejection reason when rejecting content" do
      author = create_user(role: :sympathizer)
      moderator = create_user(role: :moderator)
      thread = create_pending_thread(author: author)

      sign_in moderator

      patch moderation_item_path(type: "forum_thread", id: thread.id),
            params: { decision: "reject" },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Debes indicar un motivo de rechazo")
      expect(thread.reload).to be_pending
    end
  end
end
