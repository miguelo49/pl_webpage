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
end
