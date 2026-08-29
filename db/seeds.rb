# frozen_string_literal: true

SEED_PASSWORD = "password123"

DEMO_NEWS_TITLE = "Convenio regional impulsa participación ciudadana"
DEMO_EVENT_TITLE = "Asamblea territorial Valparaíso"

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
    description: "Avisos de objetos perdidos o encontrados en el foro.",
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
  },
  {
    name: "Noticias",
    slug: "news",
    description: "Discusión asociada a noticias publicadas.",
    position: 9
  }
].freeze

TRAINING_CATEGORIES = [
  "Organización territorial",
  "Comunicación política",
  "Marco legal y normativo"
].freeze

def seed_user(email:, role:, first_name:, last_name:, terms: true, commune: nil)
  user = User.find_or_create_by!(email: email) do |record|
    record.password = SEED_PASSWORD
    record.password_confirmation = SEED_PASSWORD
    record.first_name = first_name
    record.last_name = last_name
    record.role = role
    record.terms_accepted_at = terms ? Time.current : nil
    record.active = true
    record.residence_commune = commune if record.militant_or_above? && commune
  end

  updates = {
    first_name: first_name,
    last_name: last_name,
    role: role,
    active: true
  }
  updates[:terms_accepted_at] = Time.current if terms && user.terms_accepted_at.blank?
  updates[:residence_commune] = commune if user.militant_or_above? && commune

  user.update!(updates)
  user
end

def seed_approved_thread(topic:, user:, title:, body:)
  thread = topic.threads.find_or_create_by!(title: title, user: user) do |record|
    record.body = body
  end
  thread.update!(body: body) if thread.body != body
  thread.update_column(:status, ForumThread.statuses[:approved]) unless thread.approved?
  thread
end

puts "Seeding territories..."

region = Region.find_or_create_by!(name: "Región de Valparaíso")

VALPARAISO_COMMUNES.each do |commune_name|
  Commune.find_or_create_by!(name: commune_name, region: region)
end

valparaiso = Commune.find_by!(name: "Valparaíso", region: region)
vina = Commune.find_by!(name: "Viña del Mar", region: region)

puts "  #{region.communes.count} communes in #{region.name}"

puts "Seeding topics..."

TOPICS.each do |attrs|
  topic = Topic.find_or_create_by!(slug: attrs[:slug]) do |record|
    record.name = attrs[:name]
    record.description = attrs[:description]
    record.position = attrs[:position]
  end
  topic.update!(name: attrs[:name], description: attrs[:description], position: attrs[:position])
end

ideas_topic = Topic.find_by!(slug: "ideas")
regional_topic = Topic.find_by!(slug: "regional-politics")
news_topic = Topic.news_topic

puts "  #{Topic.count} topics"

puts "Seeding demo users..."

admin = seed_user(
  email: "admin@demo.example.com",
  role: :technical_admin,
  first_name: "Tomás",
  last_name: "Administrador",
  commune: valparaiso
)

moderator = seed_user(
  email: "moderador@demo.example.com",
  role: :moderator,
  first_name: "María",
  last_name: "Moderadora",
  commune: valparaiso
)

board_member = seed_user(
  email: "directiva@demo.example.com",
  role: :board_member,
  first_name: "Patricia",
  last_name: "Directiva",
  commune: valparaiso
)

militant = seed_user(
  email: "militante@demo.example.com",
  role: :militant,
  first_name: "Jorge",
  last_name: "Militante",
  commune: valparaiso
)

sympathizer = seed_user(
  email: "simpatizante@demo.example.com",
  role: :sympathizer,
  first_name: "Lucía",
  last_name: "Simpatizante",
  commune: nil
)

puts "  #{User.count} users (demo password: #{SEED_PASSWORD})"

puts "Seeding news and discussions..."

featured_news = News.find_or_create_by!(title: DEMO_NEWS_TITLE) do |record|
  record.summary = "El acuerdo busca fortalecer la participación en comunas de la región."
  record.body = "La directiva regional presentó un convenio con organizaciones civiles para abrir espacios de deliberación en Valparaíso y Viña del Mar. La iniciativa incluye talleres mensuales y mesas de trabajo por comuna."
  record.category = :regional
  record.user = board_member
  record.published_at = 2.days.ago
  record.status = :approved
end
featured_news.update!(
  summary: "El acuerdo busca fortalecer la participación en comunas de la región.",
  body: "La directiva regional presentó un convenio con organizaciones civiles para abrir espacios de deliberación en Valparaíso y Viña del Mar. La iniciativa incluye talleres mensuales y mesas de trabajo por comuna.",
  category: :regional,
  user: board_member,
  published_at: 2.days.ago,
  status: :approved
)

party_news = News.find_or_create_by!(title: "Declaración sobre elecciones municipales") do |record|
  record.summary = "Posicionamiento oficial del partido frente al proceso comunal."
  record.body = "El partido reafirmó su apuesta por candidaturas territoriales con participación militante y propuestas concretas para cada comuna."
  record.category = :party
  record.user = board_member
  record.published_at = 5.days.ago
  record.status = :approved
end
party_news.update!(status: :approved, user: board_member, published_at: 5.days.ago)

pending_news = News.find_or_create_by!(title: "Borrador: balance de gestión comunal") do |record|
  record.summary = "Documento en revisión antes de su publicación."
  record.body = "Este borrador resume avances y pendientes de la gestión comunal del último trimestre."
  record.category = :analysis
  record.user = board_member
  record.published_at = nil
  record.status = :pending
end
pending_news.update!(status: :pending, user: board_member)

if featured_news.thread.present?
  Comment.find_or_create_by!(
    commentable: featured_news.thread,
    user: militant,
    body: "Buena noticia, ojalá llegue pronto a mi comuna."
  ) do |comment|
    comment.status = :approved
  end.update_column(:status, Comment.statuses[:approved])
end

Reaction.find_or_create_by!(user: sympathizer, reactable: featured_news)

puts "  #{News.count} news items"

puts "Seeding events and attendances..."

assembly_event = Event.find_or_create_by!(title: DEMO_EVENT_TITLE) do |record|
  record.description = "Encuentro abierto para coordinar prioridades territoriales y definir próximas actividades."
  record.event_type = :assembly
  record.start_at = 10.days.from_now.change(hour: 18, min: 30)
  record.end_at = 10.days.from_now.change(hour: 20, min: 30)
  record.location = "Centro comunitario Valparaíso"
  record.commune = valparaiso
  record.organizer = board_member
  record.capacity = 40
end
assembly_event.update!(
  description: "Encuentro abierto para coordinar prioridades territoriales y definir próximas actividades.",
  event_type: :assembly,
  start_at: 10.days.from_now.change(hour: 18, min: 30),
  end_at: 10.days.from_now.change(hour: 20, min: 30),
  location: "Centro comunitario Valparaíso",
  commune: valparaiso,
  organizer: board_member,
  capacity: 40
)

talk_event = Event.find_or_create_by!(title: "Charla: participación digital en campañas") do |record|
  record.description = "Taller introductorio sobre herramientas digitales para militantes."
  record.event_type = :talk
  record.start_at = 5.days.from_now.change(hour: 19)
  record.end_at = 5.days.from_now.change(hour: 21)
  record.location = "Sede Viña del Mar"
  record.commune = vina
  record.organizer = board_member
  record.capacity = 25
end
talk_event.update!(organizer: board_member, commune: vina, capacity: 25)

Attendance.find_or_create_by!(user: militant, event: assembly_event) do |record|
  record.status = :confirmed
end.update!(status: :confirmed)

puts "  #{Event.count} events"

puts "Seeding initiatives..."

transport_initiative = Initiative.find_or_create_by!(title: "Mejorar conectividad en hora punta") do |record|
  record.description = "Propuesta para ampliar recorridos de buses en Valparaíso."
  record.problem = "Los tiempos de espera superan los 25 minutos en hora punta."
  record.proposal = "Coordinar con operadores un plan piloto de mayor frecuencia en corredores principales."
  record.category = "transport"
  record.user = militant
  record.commune = valparaiso
  record.status = :in_discussion
end
transport_initiative.update!(user: militant, commune: valparaiso, status: :in_discussion)

InitiativeStateChange.find_or_create_by!(
  initiative: transport_initiative,
  previous_status: Initiative.statuses[:idea],
  new_status: Initiative.statuses[:in_discussion],
  user: board_member
)

Reaction.find_or_create_by!(user: sympathizer, reactable: transport_initiative)

Comment.find_or_create_by!(
  commentable: transport_initiative,
  user: sympathizer,
  body: "Apoyo la idea, el transporte es una prioridad real."
) do |comment|
  comment.status = :approved
end.update_column(:status, Comment.statuses[:approved])

puts "  #{Initiative.count} initiatives"

puts "Seeding law proposals..."

housing_proposal = LawProposal.find_or_create_by!(name: "Protección de arrendatarios en comunas costeras") do |record|
  record.problem = "El alza de arriendos afecta desproporcionadamente a hogares de ingresos medios."
  record.rationale = "Se requiere un marco que limite aumentos abusivos y fortalezca fiscalización."
  record.objective = "Presentar una propuesta normativa con mecanismos de control y apoyo a afectados."
  record.current_text = "Artículo 1.- Establécese un régimen de protección para contratos de arrendamiento en comunas costeras..."
  record.category = "housing"
  record.user = militant
  record.commune = vina
  record.status = :discussion
end
housing_proposal.update!(user: militant, commune: vina, status: :discussion)

LawProposalVersion.find_or_create_by!(
  law_proposal: housing_proposal,
  user: board_member,
  text: "Artículo 1.- Proponese estudiar mecanismos de protección arrendaticia en comunas costeras."
)

puts "  #{LawProposal.count} law proposals"

puts "Seeding training library..."

TRAINING_CATEGORIES.each do |name|
  TrainingCategory.find_or_create_by!(name: name)
end

organization_category = TrainingCategory.find_by!(name: "Organización territorial")
communication_category = TrainingCategory.find_by!(name: "Comunicación política")

territorial_guide = TrainingMaterial.find_or_create_by!(title: "Guía de organización en comuna") do |record|
  record.description = "Manual práctico para equipos territoriales."
  record.author = "Escuela de formación"
  record.date = 3.months.ago.to_date
  record.training_category = organization_category
  record.tags = %w[territorio militancia]
end
territorial_guide.update!(
  description: "Manual práctico para equipos territoriales.",
  author: "Escuela de formación",
  date: 3.months.ago.to_date,
  training_category: organization_category,
  tags: %w[territorio militancia]
)

communication_handbook = TrainingMaterial.find_or_create_by!(title: "Comunicación clara en campañas") do |record|
  record.description = "Buenas prácticas para mensajes públicos y redes sociales."
  record.author = "Equipo de comunicaciones"
  record.date = 1.month.ago.to_date
  record.training_category = communication_category
  record.tags = %w[comunicación campaña]
end
communication_handbook.update!(
  training_category: communication_category,
  author: "Equipo de comunicaciones",
  date: 1.month.ago.to_date
)

Bookmark.find_or_create_by!(user: militant, bookmarkable: communication_handbook)
ReadMark.find_or_create_by!(user: militant, training_material: territorial_guide)

puts "  #{TrainingCategory.count} categories, #{TrainingMaterial.count} materials"

puts "Seeding community threads..."

regional_thread = seed_approved_thread(
  topic: regional_topic,
  user: board_member,
  title: "Prioridades para la región en 2026",
  body: "Compartamos qué temas deberían quedar en la agenda regional del próximo periodo."
)

ideas_thread = seed_approved_thread(
  topic: ideas_topic,
  user: militant,
  title: "Propuesta de punto limpio móvil",
  body: "¿Les parece viable coordinar un operativo mensual de reciclaje en barrios altos?"
)

Bookmark.find_or_create_by!(user: militant, bookmarkable: regional_thread)
Reaction.find_or_create_by!(user: sympathizer, reactable: regional_thread)

Comment.find_or_create_by!(
  commentable: regional_thread,
  user: sympathizer,
  body: "Yo sumaría transporte público y vivienda."
) do |comment|
  comment.status = :approved
end.update_column(:status, Comment.statuses[:approved])

pending_thread = ForumThread.find_or_create_by!(
  topic: ideas_topic,
  user: sympathizer,
  title: "Idea preliminar: feria de servicios barrial"
) do |record|
  record.body = "Estoy pensando en una feria para acercar trámites y apoyo social."
end
pending_thread.update!(body: "Estoy pensando en una feria para acercar trámites y apoyo social.")
pending_thread.update_column(:status, ForumThread.statuses[:pending]) unless pending_thread.pending?

pending_comment = Comment.find_or_create_by!(
  commentable: ideas_thread,
  user: sympathizer,
  body: "Podríamos empezar con un piloto en un sector."
)
pending_comment.update_column(:status, Comment.statuses[:pending]) unless pending_comment.pending?

puts "  #{ForumThread.count} forum threads"

puts "Seeding moderation and reports..."

Report.find_or_create_by!(
  user: sympathizer,
  reportable: pending_thread,
  reason: "Contenido duplicado en otro hilo."
)

ModerationLog.find_or_create_by!(
  moderator: moderator,
  moderatable: party_news,
  action: "approve"
) do |record|
  record.rejection_reason = nil
end

puts "  #{Report.count} reports, #{ModerationLog.count} moderation logs"

puts "Seeding admin audit sample..."

unless AuditLog.exists?(auditable: sympathizer, action: "deactivated")
  sympathizer.audit_actor = admin
  sympathizer.update!(active: false)
  sympathizer.audit_actor = admin
  sympathizer.update!(active: true)
end

puts "  #{AuditLog.count} audit logs"

puts "Seed complete."
puts "Demo accounts (password: #{SEED_PASSWORD}):"
puts "  admin@demo.example.com (admin técnico)"
puts "  moderador@demo.example.com (moderador)"
puts "  directiva@demo.example.com (directiva)"
puts "  militante@demo.example.com (militante)"
puts "  simpatizante@demo.example.com (simpatizante)"
