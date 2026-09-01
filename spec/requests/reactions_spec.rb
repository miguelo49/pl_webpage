require "rails_helper"

RSpec.describe "Reactions", type: :request do
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

  def create_thread(author:, status: :approved)
    ForumThread.create!(
      title: "Hilo visible",
      body: "Contenido del hilo",
      topic: topic,
      user: author,
      status: status
    )
  end

  describe "POST /topics/:topic_id/threads/:id/react" do
    it "toggles the reaction count via turbo stream" do
      author = create_user(role: :board_member)
      reactor = create_user(role: :sympathizer)
      thread = create_thread(author: author)

      sign_in reactor

      expect {
        post react_topic_thread_path(topic, thread),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Reaction, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("Quitar apoyo")
      expect(response.body).to include("text-primary")

      expect {
        post react_topic_thread_path(topic, thread),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Reaction, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apoyar")
    end

    it "does not allow duplicate reactions without toggling off" do
      author = create_user(role: :board_member)
      reactor = create_user(role: :sympathizer)
      thread = create_thread(author: author)

      sign_in reactor
      Reaction.create!(user: reactor, reactable: thread)

      duplicate = Reaction.new(user: reactor, reactable: thread)
      expect(duplicate).not_to be_valid
    end
  end

  describe "POST /topics/:topic_id/threads/:thread_id/comments/:id/react" do
    it "toggles the reaction count on a comment" do
      author = create_user(role: :board_member)
      reactor = create_user(role: :sympathizer)
      thread = create_thread(author: author)
      comment = Comment.create!(
        body: "Comentario útil",
        user: author,
        commentable: thread,
        status: :approved
      )

      sign_in reactor

      post react_topic_thread_comment_path(topic, thread, comment),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Quitar apoyo")

      post react_topic_thread_comment_path(topic, thread, comment),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apoyar")
      expect(Reaction.where(reactable: comment, user: reactor)).not_to exist
    end
  end
end
