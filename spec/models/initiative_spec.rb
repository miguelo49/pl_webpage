require "rails_helper"

RSpec.describe Initiative, type: :model do
  let(:region) { Region.find_or_create_by!(name: "Región de Valparaíso") }
  let(:commune) { Commune.find_or_create_by!(name: "Valparaíso", region: region) }

  let(:author) do
    User.create!(
      email: "initiative-author@example.com",
      password: "password123",
      first_name: "Ana",
      last_name: "López",
      role: :militant,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  let(:board_member) do
    User.create!(
      email: "initiative-board@example.com",
      password: "password123",
      first_name: "Carlos",
      last_name: "Rivas",
      role: :board_member,
      residence_commune: commune,
      terms_accepted_at: Time.current
    )
  end

  def build_initiative
    described_class.new(
      title: "Mejor transporte público",
      description: "Propuesta para mejorar la movilidad comunal.",
      problem: "Los buses están saturados.",
      proposal: "Ampliar recorridos.",
      category: "transport",
      user: author,
      commune: commune
    )
  end

  describe "state change history" do
    it "creates a state change record when status is updated" do
      initiative = build_initiative
      initiative.save!
      initiative.status_changed_by = board_member

      expect {
        initiative.update!(status: :in_discussion)
      }.to change(InitiativeStateChange, :count).by(1)

      state_change = initiative.state_changes.last
      expect(state_change.previous_status).to eq("idea")
      expect(state_change.new_status).to eq("in_discussion")
      expect(state_change.user).to eq(board_member)
    end

    it "does not create a state change record when status is unchanged" do
      initiative = build_initiative
      initiative.save!

      expect {
        initiative.update!(title: "Título actualizado")
      }.not_to change(InitiativeStateChange, :count)
    end
  end
end
