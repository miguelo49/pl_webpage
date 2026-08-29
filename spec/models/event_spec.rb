require "rails_helper"

RSpec.describe Event, type: :model do
  let(:user) do
    User.create!(
      email: "event-user@example.com",
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
        starts_at: 3.days.from_now,
        user: user
      )
      sooner = described_class.create!(
        title: "Evento cercano",
        description: "Descripción",
        starts_at: 1.day.from_now,
        user: user
      )
      described_class.create!(
        title: "Evento pasado",
        description: "Descripción",
        starts_at: 1.day.ago,
        user: user
      )

      expect(described_class.upcoming).to eq([ sooner, later ])
    end
  end
end
