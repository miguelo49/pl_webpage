module EventsHelper
  EVENT_TYPE_LABELS = {
    "meeting" => "Reunión",
    "assembly" => "Asamblea",
    "talk" => "Charla",
    "course" => "Curso",
    "local_activity" => "Actividad local",
    "national_event" => "Evento nacional",
    "regional_event" => "Evento regional",
    "online" => "Online"
  }.freeze

  def event_type_label(event_type)
    EVENT_TYPE_LABELS.fetch(event_type.to_s, event_type.to_s.humanize)
  end

  def capacity_label_for(event)
    return "Cupos ilimitados" if event.unlimited_capacity?

    remaining = event.remaining_capacity
    "Quedan #{remaining} de #{event.capacity} cupos"
  end

  def agenda_date_label(date)
    if date == Date.current
      "Hoy"
    elsif date == Date.current + 1
      "Mañana"
    else
      date.to_fs(:long)
    end
  end
end
