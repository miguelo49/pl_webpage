# frozen_string_literal: true

# Minimal data required for a production deploy (territories, forum topics, training taxonomy).
# Create the first technical admin via SEED_TECHNICAL_ADMIN_EMAIL and SEED_TECHNICAL_ADMIN_PASSWORD.

VALPARAISO_COMMUNES = [
  "Valparaíso",
  "Casablanca",
  "Concón",
  "Juan Fernández",
  "Puchuncaví",
  "Quilpué",
  "Quintero",
  "Villa Alemana",
  "Viña del Mar",
  "Isla de Pascua",
  "Los Andes",
  "Calle Larga",
  "Rinconada",
  "San Esteban",
  "La Ligua",
  "Cabildo",
  "Papudo",
  "Petorca",
  "Zapallar",
  "Quillota",
  "La Calera",
  "Hijuelas",
  "La Cruz",
  "Nogales",
  "San Antonio",
  "Algarrobo",
  "Cartagena",
  "El Quisco",
  "El Tabo",
  "Santo Domingo",
  "San Felipe",
  "Catemu",
  "Llaillay",
  "Panquehue",
  "Putaendo",
  "Santa María",
  "Olmué",
  "Limache"
].freeze

TOPICS = [
  { name: "Discusión sobre leyes", slug: "law-discussion", description: "Debate y análisis sobre proyectos de ley, normativas y marco legal.", position: 1 },
  { name: "Política regional", slug: "regional-politics", description: "Temas de gobierno, gestión y decisiones en la Región de Valparaíso.", position: 2 },
  { name: "Política nacional", slug: "national-politics", description: "Conversaciones sobre política, elecciones y asuntos de nivel país.", position: 3 },
  { name: "Oferta laboral", slug: "job-offers", description: "Publicación y búsqueda de oportunidades de trabajo.", position: 4 },
  { name: "Cosas perdidas", slug: "lost-and-found", description: "Avisos de objetos perdidos o encontrados en el foro.", position: 5 },
  { name: "Actividades territoriales", slug: "territorial-activities", description: "Eventos, campañas y actividades en comunas y territorios.", position: 6 },
  { name: "Ideas", slug: "ideas", description: "Propuestas, iniciativas y aportes para mejorar la organización.", position: 7 },
  { name: "Tema general", slug: "general", description: "Conversaciones abiertas que no encajan en otras categorías.", position: 8 },
  { name: "Noticias", slug: "news", description: "Discusión asociada a noticias publicadas.", position: 9 }
].freeze

TRAINING_CATEGORIES = [
  "Organización territorial",
  "Comunicación política",
  "Marco legal y normativo"
].freeze

puts "Production seed: territories..."

region = Region.find_or_create_by!(name: "Región de Valparaíso")

VALPARAISO_COMMUNES.each do |commune_name|
  Commune.find_or_create_by!(name: commune_name, region: region)
end

puts "  #{region.communes.count} communes"

puts "Production seed: topics..."

TOPICS.each do |attrs|
  topic = Topic.find_or_create_by!(slug: attrs[:slug]) do |record|
    record.name = attrs[:name]
    record.description = attrs[:description]
    record.position = attrs[:position]
  end
  topic.update!(name: attrs[:name], description: attrs[:description], position: attrs[:position])
end

puts "  #{Topic.count} topics"

puts "Production seed: training categories..."

TRAINING_CATEGORIES.each do |name|
  TrainingCategory.find_or_create_by!(name: name)
end

puts "  #{TrainingCategory.count} training categories"

admin_email = ENV["SEED_TECHNICAL_ADMIN_EMAIL"].presence
admin_password = ENV["SEED_TECHNICAL_ADMIN_PASSWORD"].presence

if admin_email && admin_password
  valparaiso = Commune.find_by(name: "Valparaíso", region: region)

  user = User.find_or_initialize_by(email: admin_email)
  user.assign_attributes(
    password: admin_password,
    password_confirmation: admin_password,
    first_name: ENV.fetch("SEED_TECHNICAL_ADMIN_FIRST_NAME", "Administrador"),
    last_name: ENV.fetch("SEED_TECHNICAL_ADMIN_LAST_NAME", "Técnico"),
    role: :technical_admin,
    active: true,
    terms_accepted_at: user.terms_accepted_at || Time.current,
    residence_commune: valparaiso
  )
  user.save!
  puts "  Technical admin ensured: #{admin_email}"
else
  puts "  Skipping technical admin (set SEED_TECHNICAL_ADMIN_EMAIL and SEED_TECHNICAL_ADMIN_PASSWORD to create one)"
end

puts "Production seed complete."
