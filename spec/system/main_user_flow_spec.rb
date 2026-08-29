# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Main user flow", type: :system do
  self.use_transactional_tests = false

  let(:password) { "password123" }
  let(:email) { "nueva.militante-#{SecureRandom.hex(4)}@example.com" }
  let(:comment_text) { "Me parece una buena noticia para la región." }

  before do
    Rails.application.load_seed
  end

  after do
    TestDatabase.truncate_all!
  end

  it "registers, completes onboarding, views news, comments, and registers for an event" do
    visit new_user_registration_path

    fill_in "Nombre", with: "Carla"
    fill_in "Apellido", with: "Muñoz"
    fill_in "Correo electrónico", with: email
    fill_in "Contraseña", with: password
    fill_in "Confirmar contraseña", with: password
    click_button "Registrarse"

    expect(page).to have_content("Términos básicos", wait: 5)

    check "Acepto los términos básicos de uso de la plataforma."
    click_button "Finalizar"

    expect(page).to have_content("Bienvenido", wait: 5)

    news = News.find_by!(title: "Convenio regional impulsa participación ciudadana")
    visit news_path(news)

    expect(page).to have_content(news.title)
    expect(page).to have_content("Discusión")

    fill_in "Tu comentario", with: comment_text
    click_button "Comentar"

    expect(page).to have_content(comment_text, wait: 5)
      .or have_content("pendiente de aprobación")

    user = User.find_by!(email: email)
    expect(user.comments.where(body: comment_text)).to exist

    event = Event.find_by!(title: "Asamblea territorial Valparaíso")
    visit event_path(event)

    expect(page).to have_content(event.title)
    click_button "Inscribirme"

    expect(page).to have_content("Estás inscrito en este evento.", wait: 5)
    expect(Attendance.find_by(user: user, event: event)).to be_registered
  end
end
