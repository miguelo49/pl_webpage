require "rails_helper"

RSpec.describe "Events", type: :request do
  let(:password) { "password123" }
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let!(:valparaiso) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }
  let!(:vina) { Commune.find_or_create_by!(name: "Viña del Mar", region: region) }

  def create_user(role: :board_member, email: nil)
    attrs = {
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.com",
      password: password,
      first_name: "Ana",
      last_name: "López",
      role: role,
      terms_accepted_at: Time.current
    }

    if User.new(role: role).militant_or_above?
      attrs[:residence_commune] = valparaiso
    end

    User.create!(attrs)
  end

  def create_event(title:, event_type:, start_at:, commune: nil, end_at: nil)
    Event.create!(
      title: title,
      description: "Descripción de #{title}",
      event_type: event_type,
      start_at: start_at,
      end_at: end_at,
      location: "Sede local",
      commune: commune,
      organizer: create_user(email: "organizer-#{SecureRandom.hex(4)}@example.com")
    )
  end

  describe "GET /events" do
    it "filters events by commune" do
      viewer = create_user(role: :sympathizer)
      local_event = create_event(
        title: "Actividad en Valparaíso",
        event_type: :local_activity,
        start_at: 2.days.from_now,
        commune: valparaiso
      )
      create_event(
        title: "Charla en Viña",
        event_type: :talk,
        start_at: 3.days.from_now,
        commune: vina
      )

      sign_in viewer
      get events_path, params: { commune_id: valparaiso.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(local_event.title)
      expect(response.body).not_to include("Charla en Viña")
    end

    it "filters events by type" do
      viewer = create_user(role: :sympathizer)
      course = create_event(
        title: "Curso de formación",
        event_type: :course,
        start_at: 2.days.from_now,
        commune: valparaiso
      )
      create_event(
        title: "Asamblea general",
        event_type: :assembly,
        start_at: 4.days.from_now,
        commune: valparaiso
      )

      sign_in viewer
      get events_path, params: { event_type: "course" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(course.title)
      expect(response.body).not_to include("Asamblea general")
    end
  end

  describe "GET /events/:id/calendar" do
    it "generates a downloadable ICS calendar file" do
      viewer = create_user(role: :sympathizer)
      event = create_event(
        title: "Taller de organización",
        event_type: :course,
        start_at: Time.zone.parse("2026-09-15 18:30:00"),
        end_at: Time.zone.parse("2026-09-15 20:00:00"),
        commune: valparaiso
      )

      sign_in viewer
      get calendar_event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/calendar")
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers["Content-Disposition"]).to include("taller-de-organizacion.ics")
      expect(response.body).to include("BEGIN:VCALENDAR")
      expect(response.body).to include("BEGIN:VEVENT")
      expect(response.body).to include("SUMMARY:Taller de organización")
      expect(response.body).to include("DTSTART:")
      expect(response.body).to include("DTEND:")
      expect(response.body).to include("END:VEVENT")
      expect(response.body).to include("END:VCALENDAR")
    end
  end
end
