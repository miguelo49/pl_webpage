require "rails_helper"

RSpec.describe Event, type: :model do
  let(:organizer) do
    User.create!(
      email: "event-organizer@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      terms_accepted_at: Time.current
    )
  end

  describe ".upcoming" do
    it "returns future events ordered by start time" do
      later = described_class.create!(
        title: "Evento lejano",
        description: "Descripción",
        event_type: :meeting,
        start_at: 3.days.from_now,
        organizer: organizer
      )
      sooner = described_class.create!(
        title: "Evento cercano",
        description: "Descripción",
        event_type: :talk,
        start_at: 1.day.from_now,
        organizer: organizer
      )
      described_class.create!(
        title: "Evento pasado",
        description: "Descripción",
        event_type: :course,
        start_at: 1.day.ago,
        organizer: organizer
      )

      expect(described_class.upcoming).to eq([ sooner, later ])
    end
  end

  describe "capacity" do
    it "allows nil capacity for unlimited events" do
      event = described_class.new(
        title: "Asamblea abierta",
        description: "Sin cupo limitado",
        event_type: :assembly,
        start_at: 1.day.from_now,
        organizer: organizer,
        capacity: nil
      )

      expect(event).to be_valid
      expect(event.unlimited_capacity?).to be(true)
    end
  end
end
