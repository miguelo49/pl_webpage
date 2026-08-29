require "rails_helper"

RSpec.describe "Community threads and comments", type: :request do
  let(:password) { "password123" }
  let!(:topic) { Topic.create!(name: "Ideas", slug: "ideas", description: "Propuestas", position: 1) }

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
      region = Region.find_or_create_by!(name: "Región de Valparaíso")
      attrs[:residence_commune] = Commune.find_or_create_by!(name: "Valparaíso", region: region)
    end

    User.create!(attrs)
  end

  def create_thread(author:, title: "Hilo visible", status: nil, topic_for: topic)
    thread = ForumThread.create!(
      title: title,
      body: "Contenido del hilo",
      topic: topic_for,
      user: author
    )
    thread.update_column(:status, status) if status
    thread.reload
  end

  describe "GET /threads" do
    it "lists approved threads from multiple topics together" do
      other_topic = Topic.create!(name: "Debate", slug: "debate", description: "Discusión", position: 2)
      viewer = create_user(role: :sympathizer)
      author = create_user(role: :sympathizer)
      ideas_thread = create_thread(author: author, title: "Hilo de ideas", status: :approved, topic_for: topic)
      debate_thread = create_thread(author: author, title: "Hilo de debate", status: :approved, topic_for: other_topic)
      create_thread(author: author, title: "Hilo pendiente", status: :pending, topic_for: topic)

      sign_in viewer
      get threads_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ideas_thread.title)
      expect(response.body).to include(debate_thread.title)
      expect(response.body).to include(topic.name)
      expect(response.body).to include(other_topic.name)
      expect(response.body).not_to include("Hilo pendiente")
    end
  end

  describe "POST /topics/:topic_id/threads" do
    it "creates a pending thread for a sympathizer" do
      user = create_user(role: :sympathizer)
      sign_in user

      expect {
        post topic_threads_path(topic), params: {
          forum_thread: { title: "Nuevo hilo", body: "Contenido del nuevo hilo" }
        }
      }.to change(ForumThread, :count).by(1)

      thread = ForumThread.last
      expect(thread.status).to eq("pending")
      expect(response).to redirect_to(threads_path)
    end
  end

  describe "POST /topics/:topic_id/threads/:thread_id/comments" do
    it "creates a comment on an approved thread" do
      author = create_user(role: :board_member)
      commenter = create_user(role: :sympathizer)
      thread = create_thread(author: author, status: :approved)

      sign_in commenter

      expect {
        post topic_thread_comments_path(topic, thread),
             params: { comment: { body: "Mi comentario" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("Mi comentario")
      expect(Comment.last.commentable).to eq(thread)
    end
  end
end
