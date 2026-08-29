# frozen_string_literal: true

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

region = Region.find_or_create_by!(name: "Región de Valparaíso")

VALPARAISO_COMMUNES.each do |commune_name|
  Commune.find_or_create_by!(name: commune_name, region: region)
end

puts "Seeded #{region.communes.count} communes for #{region.name}"

TOPICS = [
  {
    name: "Discusión sobre leyes",
    slug: "law-discussion",
    description: "Debate y análisis sobre proyectos de ley, normativas y marco legal.",
    position: 1
  },
  {
    name: "Política regional",
    slug: "regional-politics",
    description: "Temas de gobierno, gestión y decisiones en la Región de Valparaíso.",
    position: 2
  },
  {
    name: "Política nacional",
    slug: "national-politics",
    description: "Conversaciones sobre política, elecciones y asuntos de nivel país.",
    position: 3
  },
  {
    name: "Oferta laboral",
    slug: "job-offers",
    description: "Publicación y búsqueda de oportunidades de trabajo.",
    position: 4
  },
  {
    name: "Cosas perdidas",
    slug: "lost-and-found",
    description: "Avisos de objetos perdidos o encontrados en la comunidad.",
    position: 5
  },
  {
    name: "Actividades territoriales",
    slug: "territorial-activities",
    description: "Eventos, campañas y actividades en comunas y territorios.",
    position: 6
  },
  {
    name: "Ideas",
    slug: "ideas",
    description: "Propuestas, iniciativas y aportes para mejorar la organización.",
    position: 7
  },
  {
    name: "Tema general",
    slug: "general",
    description: "Conversaciones abiertas que no encajan en otras categorías.",
    position: 8
  }
].freeze

TOPICS.each do |attrs|
  Topic.find_or_create_by!(slug: attrs[:slug]) do |topic|
    topic.name = attrs[:name]
    topic.description = attrs[:description]
    topic.position = attrs[:position]
  end
end

puts "Seeded #{Topic.count} topics"
