require "rails_helper"

RSpec.describe "News", type: :request do
  let(:password) { "password123" }

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

  def create_news_item(author:, title: "Noticia de prueba")
    News.create!(
      title: title,
      summary: "Resumen de la noticia",
      body: "Contenido completo de la noticia",
      category: :party,
      user: author,
      published_at: Time.current
    )
  end

  describe "GET /news" do
    it "allows a sympathizer to view the list without the create button" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)
      create_news_item(author: author, title: "Noticia visible")

      sign_in viewer
      get news_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Noticia visible")
      expect(response.body).not_to include("Nueva noticia")
    end

    it "shows the create button to a board member" do
      user = create_user(role: :board_member)

      sign_in user
      get news_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nueva noticia")
    end

    it "filters news by category" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)
      party_news = create_news_item(author: author, title: "Noticia partido")
      News.create!(
        title: "Noticia regional",
        summary: "Resumen regional",
        body: "Contenido regional",
        category: :regional,
        user: author,
        published_at: Time.current
      )

      sign_in viewer
      get news_index_path, params: { category: "party" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(party_news.title)
      expect(response.body).not_to include("Noticia regional")
    end
  end

  describe "GET /news/:id" do
    it "allows a sympathizer to view news detail" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)
      news_item = create_news_item(author: author, title: "Detalle de noticia")

      sign_in viewer
      get news_path(news_item)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Detalle de noticia")
      expect(response.body).to include("Contenido completo de la noticia")
    end
  end

  describe "GET /news/new" do
    it "allows a board member to access the creation form" do
      user = create_user(role: :board_member)

      sign_in user
      get new_news_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nueva noticia")
      expect(response.body).to include("Publicar noticia")
    end

    it "allows a technical admin to access the creation form" do
      user = create_user(role: :technical_admin)

      sign_in user
      get new_news_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Publicar noticia")
    end

    it "denies a sympathizer access to the creation form" do
      user = create_user(role: :sympathizer)

      sign_in user
      get new_news_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("No tienes permiso para realizar esta acción.")
    end

    it "denies a moderator access to the creation form" do
      user = create_user(role: :moderator)

      sign_in user
      get new_news_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /news" do
    it "creates an associated discussion thread in the Noticias topic" do
      author = create_user(role: :board_member)

      sign_in author

      expect {
        post news_index_path, params: {
          news: {
            title: "Nueva noticia con discusión",
            summary: "Resumen para el hilo",
            body: "Contenido de la noticia",
            category: "party"
          }
        }
      }.to change(News, :count).by(1).and change(ForumThread, :count).by(1)

      news_item = News.last
      expect(news_item.thread).to be_present
      expect(news_item.thread.topic.slug).to eq(Topic::NEWS_SLUG)
      expect(news_item.thread.title).to eq("Nueva noticia con discusión")
      expect(news_item.thread.approved?).to be(true)
    end
  end

  describe "comments on news detail" do
    it "uses the associated thread for embedded discussion" do
      author = create_user(role: :board_member)
      commenter = create_user(role: :board_member, email: "commenter-#{SecureRandom.hex(4)}@example.com")
      news_item = nil

      sign_in author
      post news_index_path, params: {
        news: {
          title: "Noticia comentable",
          summary: "Resumen",
          body: "Cuerpo",
          category: "party"
        }
      }
      news_item = News.last

      sign_in commenter
      expect {
        post topic_thread_comments_path(news_item.thread.topic, news_item.thread),
             params: { comment: { body: "Comentario desde la noticia" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Comment, :count).by(1)

      get news_path(news_item)
      expect(response.body).to include("Comentario desde la noticia")
    end
  end

  describe "PATCH /news/:id" do
    it "allows a board member to update news and sync the discussion thread" do
      author = create_user(role: :board_member)
      news_item = create_news_item(author: author, title: "Título original")

      sign_in author
      patch news_path(news_item), params: {
        news: {
          title: "Título actualizado",
          summary: "Resumen actualizado",
          body: "Contenido actualizado",
          category: "party"
        }
      }

      expect(response).to redirect_to(news_path(news_item))
      news_item.reload
      expect(news_item.title).to eq("Título actualizado")
      expect(news_item.thread.title).to eq("Título actualizado")
      expect(news_item.thread.body).to include("Resumen actualizado")
    end

    it "denies a militant from updating news" do
      author = create_user(role: :board_member)
      militant = create_user(role: :militant)
      news_item = create_news_item(author: author)

      sign_in militant
      patch news_path(news_item), params: {
        news: { title: "Intento de edición", summary: "X", body: "Y", category: "party" }
      }

      expect(response).to redirect_to(root_path)
      expect(news_item.reload.title).to eq("Noticia de prueba")
    end

    it "allows a board member to remove the featured image" do
      author = create_user(role: :board_member)
      news_item = create_news_item(author: author)
      news_item.featured_image.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/avatar.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )

      sign_in author
      patch news_path(news_item), params: {
        news: {
          title: news_item.title,
          summary: news_item.summary,
          body: news_item.body,
          category: "party",
          remove_featured_image: "1"
        }
      }

      expect(response).to redirect_to(news_path(news_item))
      expect(news_item.reload.featured_image).not_to be_attached
    end
  end

  describe "DELETE /news/:id" do
    it "allows a board member to destroy news and its discussion thread" do
      author = create_user(role: :board_member)
      news_item = create_news_item(author: author)
      thread = news_item.thread

      sign_in author

      expect {
        delete news_path(news_item)
      }.to change(News, :count).by(-1).and change(ForumThread, :count).by(-1)

      expect(response).to redirect_to(news_index_path)
      expect { thread.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "denies a militant from destroying news" do
      author = create_user(role: :board_member)
      militant = create_user(role: :militant)
      news_item = create_news_item(author: author)

      sign_in militant

      expect {
        delete news_path(news_item)
      }.not_to change(News, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /news/:id/edit" do
    it "allows a board member to access the edit form" do
      author = create_user(role: :board_member)
      news_item = create_news_item(author: author)

      sign_in author
      get edit_news_path(news_item)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Editar noticia")
      expect(response.body).to include("Guardar cambios")
    end

    it "denies a militant access to the edit form" do
      author = create_user(role: :board_member)
      militant = create_user(role: :militant)
      news_item = create_news_item(author: author)

      sign_in militant
      get edit_news_path(news_item)

      expect(response).to redirect_to(root_path)
    end
  end
end
