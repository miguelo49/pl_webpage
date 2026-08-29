require "rails_helper"

RSpec.describe Attendance, type: :model do
  let(:organizer) do
    User.create!(
      email: "attendance-organizer@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end

  let(:event) do
    Event.create!(
      title: "Taller con cupo",
      description: "Capacidad limitada",
      event_type: :course,
      start_at: 2.days.from_now,
      organizer: organizer,
      capacity: 2
    )
  end

  def create_user(email)
    User.create!(
      email: email,
      password: "password123",
      first_name: "Usuario",
      last_name: "Prueba",
      terms_accepted_at: Time.current
    )
  end

  describe "capacity validation" do
    it "does not allow registrations beyond event capacity" do
      create_user("user-1@example.com")
      create_user("user-2@example.com")
      third_user = create_user("user-3@example.com")

      2.times do |index|
        described_class.create!(
          user: create_user("filled-#{index}@example.com"),
          event: event,
          status: :registered
        )
      end

      overflow = described_class.new(user: third_user, event: event, status: :registered)

      expect(overflow).not_to be_valid
      expect(overflow.errors[:base]).to include("No quedan cupos disponibles")
    end

    it "frees a spot when an attendance is cancelled" do
      first_user = create_user("first@example.com")
      second_user = create_user("second@example.com")
      third_user = create_user("third@example.com")

      first_attendance = described_class.create!(user: first_user, event: event, status: :registered)
      described_class.create!(user: second_user, event: event, status: :registered)

      first_attendance.update!(status: :cancelled)

      replacement = described_class.new(user: third_user, event: event, status: :registered)

      expect(replacement).to be_valid
    end
  end

  describe "uniqueness" do
    it "allows only one attendance per user and event" do
      user = create_user("unique@example.com")
      described_class.create!(user: user, event: event, status: :registered)

      duplicate = described_class.new(user: user, event: event, status: :confirmed)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
  end
end
