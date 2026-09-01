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

    it "filters threads by a single topic" do
      other_topic = Topic.create!(name: "Debate", slug: "debate", description: "Discusión", position: 2)
      viewer = create_user(role: :sympathizer)
      author = create_user(role: :sympathizer)
      ideas_thread = create_thread(author: author, title: "Hilo de ideas", status: :approved, topic_for: topic)
      debate_thread = create_thread(author: author, title: "Hilo de debate", status: :approved, topic_for: other_topic)

      sign_in viewer
      get threads_path(topic_ids: [ topic.id ])

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ideas_thread.title)
      expect(response.body).not_to include(debate_thread.title)
    end

    it "filters threads by multiple topics" do
      other_topic = Topic.create!(name: "Debate", slug: "debate", description: "Discusión", position: 2)
      third_topic = Topic.create!(name: "Avisos", slug: "avisos", description: "Avisos", position: 3)
      viewer = create_user(role: :sympathizer)
      author = create_user(role: :sympathizer)
      ideas_thread = create_thread(author: author, title: "Hilo de ideas", status: :approved, topic_for: topic)
      debate_thread = create_thread(author: author, title: "Hilo de debate", status: :approved, topic_for: other_topic)
      avisos_thread = create_thread(author: author, title: "Hilo de avisos", status: :approved, topic_for: third_topic)

      sign_in viewer
      get threads_path(topic_ids: [ topic.id, other_topic.id ])

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ideas_thread.title)
      expect(response.body).to include(debate_thread.title)
      expect(response.body).not_to include(avisos_thread.title)
    end

    it "paginates threads" do
      viewer = create_user(role: :sympathizer)
      author = create_user(role: :sympathizer)
      11.times do |i|
        create_thread(author: author, title: "Hilo paginado #{i}", status: :approved)
      end

      sign_in viewer
      get threads_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hilo paginado 10")
      expect(response.body).not_to include("Hilo paginado 0")
      expect(response.body).to include("Página 1 de 2")

      get threads_path(page: 2)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hilo paginado 0")
      expect(response.body).not_to include("Hilo paginado 10")
    end

    it "does not list news discussion threads in the forum" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)
      news_item = News.create!(
        title: "Noticia con hilo interno",
        summary: "Resumen",
        body: "Contenido",
        category: :party,
        user: author,
        published_at: Time.current
      )

      sign_in viewer
      get threads_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(news_item.thread.title)
      expect(response.body).not_to include("data-topic-id=\"#{news_item.thread.topic_id}\"")
    end
  end

  describe "POST /topics/:topic_id/threads" do
    it "creates an approved thread for a sympathizer" do
      user = create_user(role: :sympathizer)
      sign_in user

      expect {
        post topic_threads_path(topic), params: {
          forum_thread: { title: "Nuevo hilo", body: "Contenido del nuevo hilo" }
        }
      }.to change(ForumThread, :count).by(1)

      thread = ForumThread.last
      expect(thread.status).to eq("approved")
      expect(response).to redirect_to(topic_thread_path(topic, thread))
    end

    it "rejects thread creation in the internal Noticias topic" do
      news_topic = Topic.news_topic
      militant = create_user(role: :militant)

      sign_in militant

      expect {
        post topic_threads_path(news_topic), params: {
          forum_thread: { title: "Intento de noticia", body: "Contenido" }
        }
      }.not_to change(ForumThread, :count)

      expect(response).to redirect_to(threads_path)
      follow_redirect!
      expect(response.body).to include("Las noticias se publican desde la sección Noticias.")
    end
  end

  describe "GET /topics/:topic_id/threads/:id" do
    it "allows a sympathizer to view an approved thread" do
      author = create_user(role: :sympathizer)
      viewer = create_user(role: :sympathizer)
      thread = create_thread(author: author, title: "Hilo público", status: :approved)

      sign_in viewer
      get topic_thread_path(topic, thread)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hilo público")
      expect(response.body).not_to include("No tienes permiso")
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
      expect(Comment.last.status).to eq("approved")
    end

    it "creates a reply to a top-level comment" do
      author = create_user(role: :board_member)
      commenter = create_user(role: :sympathizer)
      thread = create_thread(author: author, status: :approved)
      parent_comment = thread.comments.create!(body: "Comentario padre", user: author)

      sign_in commenter

      expect {
        post topic_thread_comments_path(topic, thread),
             params: { comment: { body: "Mi respuesta", parent_id: parent_comment.id } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Comment, :count).by(1)

      reply = Comment.last
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mi respuesta")
      expect(reply.parent).to eq(parent_comment)
      expect(reply.reply?).to be(true)
    end
  end
end
