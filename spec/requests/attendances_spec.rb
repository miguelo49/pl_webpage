require "rails_helper"

RSpec.describe "Event attendances", type: :request do
  let(:password) { "password123" }

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

  def create_event(capacity: 1)
    organizer = create_user(role: :board_member, email: "organizer-#{SecureRandom.hex(4)}@example.com")

    Event.create!(
      title: "Evento con cupos",
      description: "Evento de prueba",
      event_type: :meeting,
      start_at: 2.days.from_now,
      organizer: organizer,
      capacity: capacity
    )
  end

  describe "POST /events/:event_id/attendance" do
    it "registers the current user and updates remaining capacity" do
      event = create_event(capacity: 2)
      user = create_user(role: :sympathizer)

      sign_in user

      expect {
        post event_attendance_path(event),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Attendance, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Quedan 1 de 2 cupos")
      expect(response.body).to include("Estás inscrito")
      expect(Attendance.find_by(user: user, event: event)).to be_registered
    end

    it "does not register beyond capacity" do
      event = create_event(capacity: 1)
      first_user = create_user(role: :sympathizer, email: "first@example.com")
      second_user = create_user(role: :sympathizer, email: "second@example.com")

      Attendance.create!(user: first_user, event: event, status: :registered)

      sign_in second_user
      post event_attendance_path(event),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("No quedan cupos disponibles")
      expect(Attendance.find_by(user: second_user, event: event)).to be_nil
    end
  end

  describe "PATCH /events/:event_id/attendance" do
    it "cancels an attendance and frees capacity for another user" do
      event = create_event(capacity: 1)
      first_user = create_user(role: :sympathizer, email: "first-cancel@example.com")
      second_user = create_user(role: :sympathizer, email: "second-cancel@example.com")

      sign_in first_user
      post event_attendance_path(event),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      patch event_attendance_path(event),
            params: { attendance: { status: :cancelled } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Quedan 1 de 1 cupos")

      sign_in second_user
      expect {
        post event_attendance_path(event),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Attendance, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(Attendance.find_by(user: second_user, event: event)).to be_registered
    end
  end
end
