require "rails_helper"

RSpec.describe "Political context", type: :request do
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

  describe "GET /political_contexts" do
    it "shows upcoming events and relevant recent news" do
      author = create_user(role: :board_member)
      viewer = create_user(role: :sympathizer)

      News.create!(
        title: "Reforma legislativa",
        summary: "Resumen legislativo",
        body: "Contenido legislativo",
        category: :legislative,
        user: author,
        published_at: Time.current
      )

      News.create!(
        title: "Actividad territorial",
        summary: "Resumen de actividad",
        body: "Contenido de actividad",
        category: :activity,
        user: author,
        published_at: Time.current
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
      get political_contexts_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Contexto político")
      expect(response.body).to include("Próximos eventos")
      expect(response.body).to include("Noticias recientes")
      expect(response.body).to include("Asamblea regional")
      expect(response.body).to include("Reforma legislativa")
      expect(response.body).not_to include("Evento pasado")
      expect(response.body).not_to include("Actividad territorial")
    end

    it "requires authentication" do
      get political_contexts_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
