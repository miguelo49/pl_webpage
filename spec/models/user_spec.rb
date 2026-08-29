require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "requires first_name" do
      user = User.new(last_name: "Pérez", email: "test@example.com", password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it "requires last_name" do
      user = User.new(first_name: "Juan", email: "test@example.com", password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end
  end

  describe "role enum" do
    it "defines expected roles in English" do
      expect(User.roles.keys).to contain_exactly(
        "sympathizer", "militant", "board_member", "moderator", "technical_admin"
      )
    end

    it "defaults new users to sympathizer" do
      user = User.new(email: "new@example.com", password: "password123", first_name: "Ana", last_name: "López")
      expect(user.role).to eq("sympathizer")
    end

    it "persists sympathizer as default on create" do
      user = User.create!(
        email: "default@example.com",
        password: "password123",
        first_name: "Carlos",
        last_name: "Ruiz"
      )
      expect(user.reload.role).to eq("sympathizer")
    end
  end

  describe "commune references" do
    let(:region) { Region.create!(name: "Región de Valparaíso") }
    let(:commune) { Commune.create!(name: "Valparaíso", region: region) }

    def build_user(role:, residence_commune: nil)
      User.new(
        email: "#{role}@example.com",
        password: "password123",
        first_name: "Ana",
        last_name: "López",
        role: role,
        residence_commune: residence_commune
      )
    end

    it "allows a sympathizer without a residence commune" do
      user = build_user(role: :sympathizer)

      expect(user).to be_valid
    end

    it "requires a residence commune for a militant" do
      user = build_user(role: :militant)

      expect(user).not_to be_valid
      expect(user.errors[:residence_commune]).to include("can't be blank")
    end

    it "allows a militant with a residence commune" do
      user = build_user(role: :militant, residence_commune: commune)

      expect(user).to be_valid
    end

    it "requires a residence commune for board_member and above" do
      user = build_user(role: :board_member)

      expect(user).not_to be_valid
      expect(user.errors[:residence_commune]).to include("can't be blank")
    end

    it "does not require work or study communes for a militant" do
      user = build_user(role: :militant, residence_commune: commune)

      expect(user.work_commune).to be_nil
      expect(user.study_commune).to be_nil
      expect(user).to be_valid
    end
  end

  describe "onboarding status" do
    it "is incomplete without accepted terms" do
      user = User.new(
        email: "test@example.com",
        password: "password123",
        first_name: "Ana",
        last_name: "López"
      )
      expect(user.complete?).to be(false)
    end

    it "is complete with profile and terms" do
      user = User.new(
        email: "test@example.com",
        password: "password123",
        first_name: "Ana",
        last_name: "López",
        terms_accepted_at: Time.current
      )
      expect(user.complete?).to be(true)
    end
  end
end
