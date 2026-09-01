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

  describe "POST /events" do
    let(:event_params) do
      {
        event: {
          title: "Nueva actividad",
          description: "Descripción del evento",
          event_type: "meeting",
          start_at: 2.days.from_now.strftime("%Y-%m-%dT%H:%M"),
          commune_id: valparaiso.id,
          location: "Sede local"
        }
      }
    end

    it "creates a pending event for militants" do
      militant = create_user(role: :militant)

      sign_in militant
      expect {
        post events_path, params: event_params
      }.to change(Event, :count).by(1)

      event = Event.order(:created_at).last
      expect(event).to be_pending
      expect(event.organizer).to eq(militant)
      expect(response).to redirect_to(event_path(event))
      follow_redirect!
      expect(response.body).to include("enviado a moderación")
    end

    it "does not show pending militant events to other users in the index" do
      militant = create_user(role: :militant)
      viewer = create_user(role: :sympathizer, email: "viewer-#{SecureRandom.hex(4)}@example.com")

      sign_in militant
      post events_path, params: event_params
      event = Event.order(:created_at).last

      sign_in viewer
      get events_path

      expect(response.body).not_to include(event.title)
    end

    it "creates an approved event for board members" do
      board_member = create_user(role: :board_member)

      sign_in board_member
      post events_path, params: event_params

      event = Event.order(:created_at).last
      expect(event).to be_approved
      expect(response).to redirect_to(event_path(event))

      sign_in create_user(role: :sympathizer, email: "viewer2-#{SecureRandom.hex(4)}@example.com")
      get events_path
      expect(response.body).to include(event.title)
    end

    it "adds pending militant events to the moderation queue" do
      militant = create_user(role: :militant)
      moderator = create_user(role: :moderator, email: "moderator-#{SecureRandom.hex(4)}@example.com")

      sign_in militant
      post events_path, params: event_params
      event = Event.order(:created_at).last

      sign_in moderator
      get moderation_root_path

      expect(response.body).to include(event.title)
    end

    it "forbids sympathizers from creating events" do
      sympathizer = create_user(role: :sympathizer)

      sign_in sympathizer
      get new_event_path
      expect(response).to have_http_status(:forbidden)
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
