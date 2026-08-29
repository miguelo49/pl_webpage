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
