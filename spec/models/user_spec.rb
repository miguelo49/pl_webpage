require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "requires nombre" do
      user = User.new(apellido: "Pérez", email: "test@example.com", password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:nombre]).to include("can't be blank")
    end

    it "requires apellido" do
      user = User.new(nombre: "Juan", email: "test@example.com", password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:apellido]).to include("can't be blank")
    end
  end

  describe "role enum" do
    it "defines expected roles in English" do
      expect(User.roles.keys).to contain_exactly(
        "sympathizer", "militant", "board_member", "moderator", "technical_admin"
      )
    end

    it "defaults new users to sympathizer" do
      user = User.new(email: "new@example.com", password: "password123", nombre: "Ana", apellido: "López")
      expect(user.role).to eq("sympathizer")
    end

    it "persists sympathizer as default on create" do
      user = User.create!(
        email: "default@example.com",
        password: "password123",
        nombre: "Carlos",
        apellido: "Ruiz"
      )
      expect(user.reload.role).to eq("sympathizer")
    end
  end
end
