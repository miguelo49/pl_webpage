require "rails_helper"

RSpec.describe "Bookmarks", type: :request do
  let(:password) { "password123" }
  let!(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }

  def create_user(role: :sympathizer, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      region = Region.find_or_create_by!(name: "Región de Valparaíso")
      attrs[:residence_commune] = Commune.find_or_create_by!(name: "Valparaíso", region: region)
    end

    User.create!(attrs)
  end

  def create_thread(author:, title: "Hilo visible", status: :approved)
    ForumThread.create!(
      title: title,
      body: "Contenido del hilo",
      topic: topic,
      user: author,
      status: status
    )
  end

  describe "POST /topics/:topic_id/threads/:id/bookmark" do
    it "toggles saving a thread via turbo stream" do
      author = create_user(role: :board_member)
      saver = create_user(role: :sympathizer)
      thread = create_thread(author: author, title: "Hilo para guardar")

      sign_in saver

      expect {
        post bookmark_topic_thread_path(topic, thread),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Bookmark, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("Guardado")

      expect {
        post bookmark_topic_thread_path(topic, thread),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Bookmark, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Guardar")
    end
  end

  describe "GET /profile" do
    it "lists saved threads for the current user" do
      author = create_user(role: :board_member)
      saver = create_user(role: :sympathizer)
      saved_thread = create_thread(author: author, title: "Hilo guardado en perfil")
      other_thread = create_thread(author: author, title: "Hilo no guardado")

      sign_in saver
      Bookmark.create!(user: saver, bookmarkable: saved_thread)

      get profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Guardados")
      expect(response.body).to include(saved_thread.title)
      expect(response.body).not_to include(other_thread.title)
    end

    it "removes a thread from saved list after unbookmarking" do
      author = create_user(role: :board_member)
      saver = create_user(role: :sympathizer)
      thread = create_thread(author: author, title: "Hilo temporal")

      sign_in saver

      post bookmark_topic_thread_path(topic, thread),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
      get profile_path
      expect(response.body).to include(thread.title)

      post bookmark_topic_thread_path(topic, thread),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
      get profile_path
      expect(response.body).to include("No tienes hilos guardados todavía")
      expect(response.body).not_to include(thread.title)
    end
  end
end
