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

def seed_news(title:, summary:, body:, category:, user:, published_at:, status: :approved)
  news = News.find_or_create_by!(title: title) do |record|
    record.summary = summary
    record.body = body
    record.category = category
    record.user = user
    record.published_at = published_at
    record.status = status
  end

  news.update!(
    summary: summary,
    body: body,
    category: category,
    user: user,
    published_at: published_at,
    status: status
  )
  news.update_columns(created_at: published_at, updated_at: published_at) if published_at.present?
  news
end

def seed_event(title:, description:, event_type:, start_at:, end_at:, location:, commune:, organizer:, capacity:, posted_at:)
  event = Event.find_or_create_by!(title: title) do |record|
    record.description = description
    record.event_type = event_type
    record.start_at = start_at
    record.end_at = end_at
    record.location = location
    record.commune = commune
    record.organizer = organizer
    record.capacity = capacity
  end

  event.update!(
    description: description,
    event_type: event_type,
    start_at: start_at,
    end_at: end_at,
    location: location,
    commune: commune,
    organizer: organizer,
    capacity: capacity
  )
  event.update_columns(created_at: posted_at, updated_at: posted_at)
  event
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
featured_news.update_columns(created_at: 2.days.ago, updated_at: 2.days.ago)

party_news = News.find_or_create_by!(title: "Declaración sobre elecciones municipales") do |record|
  record.summary = "Posicionamiento oficial del partido frente al proceso comunal."
  record.body = "El partido reafirmó su apuesta por candidaturas territoriales con participación militante y propuestas concretas para cada comuna."
  record.category = :party
  record.user = board_member
  record.published_at = 5.days.ago
  record.status = :approved
end
party_news.update!(status: :approved, user: board_member, published_at: 5.days.ago)
party_news.update_columns(created_at: 5.days.ago, updated_at: 5.days.ago)

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

ADDITIONAL_NEWS = [
  {
    title: "Análisis: panorama legislativo del segundo semestre",
    summary: "Balance de los proyectos en tramitación y prioridades del partido.",
    body: "La directiva nacional revisó el calendario legislativo y definió ejes de seguimiento para comisiones clave.",
    category: :analysis,
    published_at: 1.day.ago
  },
  {
    title: "Declaración sobre reforma previsional",
    summary: "Posición del partido frente al debate en el Congreso.",
    body: "Reafirmamos la necesidad de un sistema más solidario, con mayor transparencia y participación ciudadana.",
    category: :statement,
    published_at: 3.days.ago
  },
  {
    title: "Campaña de afiliación en comunas del litoral",
    summary: "Jornadas de puerta a puerta en Valparaíso y Viña del Mar.",
    body: "Durante dos semanas, equipos territoriales recorrerán barrios para conversar con vecinos y difundir propuestas.",
    category: :activity,
    published_at: 4.days.ago
  },
  {
    title: "Propuesta nacional de modernización del Estado",
    summary: "Documento base para el debate interno del partido.",
    body: "El texto propone simplificar trámites, fortalecer la digitalización y mejorar la rendición de cuentas.",
    category: :national,
    published_at: 6.days.ago
  },
  {
    title: "Informe territorial: avances en Quilpué",
    summary: "Resumen de actividades y contactos con organizaciones locales.",
    body: "El equipo de Quilpué reportó reuniones con juntas de vecinos y avances en la agenda de seguridad barrial.",
    category: :regional,
    published_at: 7.days.ago
  },
  {
    title: "Proyecto de ley sobre transparencia municipal",
    summary: "Iniciativa impulsada por la bancada liberal.",
    body: "La propuesta exige publicar contratos y audiencias públicas obligatorias para obras mayores.",
    category: :legislative,
    published_at: 8.days.ago
  },
  {
    title: "Comunicado: elecciones internas de directivas",
    summary: "Calendario y reglas para el proceso de renovación.",
    body: "Las elecciones se realizarán en asambleas territoriales durante el mes de octubre.",
    category: :party,
    published_at: 9.days.ago
  },
  {
    title: "Encuentro con emprendedores locales",
    summary: "Actividad de vinculación con el sector productivo regional.",
    body: "Participaron más de 40 emprendedores en un diálogo sobre simplificación regulatoria y acceso a financiamiento.",
    category: :activity,
    published_at: 10.days.ago
  },
  {
    title: "Opinión: descentralización y autonomía regional",
    summary: "Columna de la directiva regional publicada en medios locales.",
    body: "Argumentamos que más competencias para gobiernos regionales permiten respuestas más ágiles a problemas territoriales.",
    category: :analysis,
    published_at: 12.days.ago
  },
  {
    title: "Nota de prensa: apoyo a proyecto de vivienda social",
    summary: "El partido respalda iniciativa para ampliar subsidios.",
    body: "La propuesta busca reducir listas de espera y priorizar familias en situación de vulnerabilidad habitacional.",
    category: :national,
    published_at: 14.days.ago
  },
  {
    title: "Jornada de formación para nuevos militantes",
    summary: "Programa introductorio sobre historia y principios liberales.",
    body: "La escuela de formación abrirá inscripciones para módulos presenciales y online durante septiembre.",
    category: :party,
    published_at: 16.days.ago
  },
  {
    title: "Balance de gestión: primer semestre regional",
    summary: "Informe de actividades y metas cumplidas en la región.",
    body: "Se destacan las mesas de trabajo por comuna, la participación en concejos comunales y la campaña de afiliación.",
    category: :regional,
    published_at: 18.days.ago
  },
  {
    title: "Mesa redonda: seguridad ciudadana en barrios",
    summary: "Diálogo con vecinos y autoridades locales en Valparaíso.",
    body: "Participaron concejales y representantes de juntas de vecinos para abordar iluminación, patrullaje y prevención.",
    category: :activity,
    published_at: 20.days.ago
  },
  {
    title: "Carta abierta a candidatos independientes",
    summary: "Invitación a construir acuerdos programáticos locales.",
    body: "El partido ofrece dialogar con candidaturas que compartan valores de libertad, transparencia y participación.",
    category: :statement,
    published_at: 22.days.ago
  },
  {
    title: "Seminario: financiamiento de campañas locales",
    summary: "Capacitación para tesoreros de comunas.",
    body: "Se revisaron normas del SERVEL, plazos de rendición y buenas prácticas de control interno.",
    category: :legislative,
    published_at: 24.days.ago
  },
  {
    title: "Alianza con fundación educativa regional",
    summary: "Convenio para talleres de ciudadanía en liceos.",
    body: "El acuerdo permitirá llegar a estudiantes de cuarto medio en diez establecimientos de la región.",
    category: :regional,
    published_at: 26.days.ago
  },
  {
    title: "Informe: participación en elecciones primarias",
    summary: "Cifras de votación y lecciones para el proceso interno.",
    body: "La directiva analizó la participación por comuna y propuso ajustes al calendario de difusión.",
    category: :party,
    published_at: 28.days.ago
  }
].freeze

ADDITIONAL_NEWS.each do |attrs|
  seed_news(
    title: attrs[:title],
    summary: attrs[:summary],
    body: attrs[:body],
    category: attrs[:category],
    user: board_member,
    published_at: attrs[:published_at]
  )
end

commented_news = News.find_by!(title: "Declaración sobre reforma previsional")
if commented_news.thread.present?
  Comment.find_or_create_by!(
    commentable: commented_news.thread,
    user: sympathizer,
    body: "Me parece una posición equilibrada, gracias por compartirla."
  ) do |comment|
    comment.status = :approved
  end.update_column(:status, Comment.statuses[:approved])
end

Reaction.find_or_create_by!(user: militant, reactable: commented_news)

puts "  #{News.count} news items"

puts "Seeding events and attendances..."

Event.where(title: "Charla: participación digital en campañas").destroy_all

september_talk_start = Time.zone.local(Time.current.year, 9, 5, 19, 0)
september_talk_end = Time.zone.local(Time.current.year, 9, 5, 21, 0)

assembly_event = seed_event(
  title: DEMO_EVENT_TITLE,
  description: "Encuentro abierto para coordinar prioridades territoriales y definir próximas actividades.",
  event_type: :assembly,
  start_at: 10.days.from_now.change(hour: 18, min: 30),
  end_at: 10.days.from_now.change(hour: 20, min: 30),
  location: "Centro comunitario Valparaíso",
  commune: valparaiso,
  organizer: board_member,
  capacity: 40,
  posted_at: 1.day.ago
)

talk_event = seed_event(
  title: "Charla: participación ciudadana — 5 de septiembre",
  description: "Espacio abierto para conversar sobre mecanismos de participación y organización comunitaria.",
  event_type: :talk,
  start_at: september_talk_start,
  end_at: september_talk_end,
  location: "Sede Viña del Mar",
  commune: vina,
  organizer: board_member,
  capacity: 25,
  posted_at: 3.hours.ago
)

seed_event(
  title: "Curso: herramientas de campaña digital",
  description: "Taller práctico sobre redes sociales, mensajes y coordinación online.",
  event_type: :course,
  start_at: 14.days.from_now.change(hour: 18),
  end_at: 14.days.from_now.change(hour: 20, min: 30),
  location: "Sala de capacitación Valparaíso",
  commune: valparaiso,
  organizer: board_member,
  capacity: 30,
  posted_at: 2.days.ago
)

seed_event(
  title: "Actividad local: limpieza de playa en Concón",
  description: "Convocatoria abierta para militantes y simpatizantes del litoral norte.",
  event_type: :local_activity,
  start_at: 7.days.from_now.change(hour: 10),
  end_at: 7.days.from_now.change(hour: 13),
  location: "Playa Concón",
  commune: Commune.find_by!(name: "Concón", region: region),
  organizer: board_member,
  capacity: nil,
  posted_at: 4.days.ago
)

seed_event(
  title: "Webinar: marco legal para candidaturas",
  description: "Sesión online sobre requisitos, plazos y obligaciones de reporte.",
  event_type: :online,
  start_at: 20.days.from_now.change(hour: 19),
  end_at: 20.days.from_now.change(hour: 20, min: 30),
  location: "Zoom",
  commune: nil,
  organizer: board_member,
  capacity: 100,
  posted_at: 5.days.ago
)

seed_event(
  title: "Encuentro regional de directivas comunales",
  description: "Coordinación entre equipos de distintas comunas de la región.",
  event_type: :regional_event,
  start_at: 25.days.from_now.change(hour: 17),
  end_at: 25.days.from_now.change(hour: 20),
  location: "Hotel Seminario Viña del Mar",
  commune: vina,
  organizer: board_member,
  capacity: 60,
  posted_at: 6.days.ago
)

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
