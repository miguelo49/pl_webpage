require "rails_helper"

RSpec.describe "Home feed", type: :request do
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

  describe "GET /" do
    it "shows approved news and upcoming events in the feed" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)

      News.create!(
        title: "Reforma legislativa",
        summary: "Resumen legislativo",
        body: "Contenido legislativo",
        category: :legislative,
        user: author,
        published_at: 1.hour.ago,
        status: :approved
      )

      News.create!(
        title: "Borrador interno",
        summary: "No publicado",
        body: "Contenido pendiente",
        category: :analysis,
        user: author,
        status: :pending
      )

      Event.create!(
        title: "Asamblea regional",
        description: "Encuentro con militantes",
        event_type: :assembly,
        location: "Valparaíso",
        start_at: 2.days.from_now,
        organizer: author
      )

      Event.create!(
        title: "Evento pasado",
        description: "Ya ocurrió",
        event_type: :meeting,
        start_at: 2.days.ago,
        organizer: author
      )

      sign_in viewer
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Inicio")
      expect(response.body).to include("Reforma legislativa")
      expect(response.body).to include("Asamblea regional")
      expect(response.body).to include("Noticia")
      expect(response.body).to include("Evento")
      expect(response.body).not_to include("Borrador interno")
      expect(response.body).not_to include("Evento pasado")
    end

    it "requires authentication" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns turbo stream for subsequent pages" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)

      12.times do |index|
        News.create!(
          title: "Noticia #{index}",
          summary: "Resumen #{index}",
          body: "Contenido #{index}",
          category: :party,
          user: author,
          published_at: index.hours.ago,
          status: :approved
        )
      end

      sign_in viewer
      get root_path, params: { page: 2 }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("Noticia 10")
    end

    it "returns no content when requesting a page beyond the feed" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)

      News.create!(
        title: "Única noticia",
        summary: "Resumen",
        body: "Contenido",
        category: :party,
        user: author,
        published_at: Time.current,
        status: :approved
      )

      sign_in viewer
      get root_path, params: { page: 3 }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:no_content)
    end
  end
end
