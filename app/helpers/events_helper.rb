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

  EVENT_TYPE_ICON_PATHS = {
    "meeting" => "M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z",
    "assembly" => "M12 12.75c1.63 0 3.07.39 4.24.9 1.08.48 1.76 1.56 1.76 2.73V18H6v-1.62c0-1.17.68-2.25 1.76-2.73 1.17-.52 2.61-.9 4.24-.9zM4 13c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm1.13 1.1c-.37-.06-.74-.1-1.13-.1-.99 0-1.93.21-2.78.58C.48 14.9 0 15.62 0 16.43V18h4.5v-1.07c0-.59.21-1.15.63-1.57zM20 13c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm4 3h-2v-1.07c0-.59-.21-1.15-.63-1.57C20.93 13.21 20 13 19 13c-.39 0-.76.04-1.13.1.41.59.63 1.3.63 2.07V18h2v-2zM12 6c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3z",
    "talk" => "M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.91-3c-.49 0-.9.36-.98.85C16.52 14.2 14.47 16 12 16s-4.52-1.8-4.93-4.15c-.08-.49-.49-.85-.98-.85-.61 0-1.09.54-1 1.14.49 3 2.89 5.35 5.91 5.78V20c0 .55.45 1 1 1s1-.45 1-1v-2.08c3.02-.43 5.42-2.78 5.91-5.78.1-.6-.39-1.14-1-1.14z",
    "course" => "M5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82zM12 3L1 9l11 6 9-4.91V17h2V9L12 3z",
    "local_activity" => "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
    "national_event" => "M12 7V3H2v18h20V7H12zM6 19H4v-2h2v2zm0-4H4v-2h2v2zm0-4H4V9h2v2zm0-4H4V5h2v2zm4 12H8v-2h2v2zm0-4H8v-2h2v2zm0-4H8V9h2v2zm0-4H8V5h2v2zm10 12h-8v-2h2v-2h-2v-2h2v-2h-2V9h8v10zm-2-8h-2v2h2v-2zm0 4h-2v2h2v-2z",
    "regional_event" => "M20.5 3l-.16.03L15 5.1 9 3 3.36 4.9c-.21.07-.36.25-.36.48V20.5c0 .28.22.5.5.5l.16-.03L9 18.9l6 2.1 5.64-1.9c.21-.07.36-.25.36-.48V3.5c0-.28-.22-.5-.5-.5zM15 19l-6-2.11V5l6 2.11V19z",
    "online" => "M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z"
  }.freeze

  EVENT_TYPE_ICON_COLORS = {
    "meeting" => "text-primary",
    "assembly" => "text-accent",
    "talk" => "text-primary",
    "course" => "text-accent",
    "local_activity" => "text-secondary",
    "national_event" => "text-accent",
    "regional_event" => "text-secondary",
    "online" => "text-primary"
  }.freeze

  def event_type_label(event_type)
    EVENT_TYPE_LABELS.fetch(event_type.to_s, event_type.to_s.humanize)
  end

  def event_type_icon(event_type, size: :sm)
    size_class = size == :sm ? "h-3 w-3" : "h-3.5 w-3.5"
    color_class = EVENT_TYPE_ICON_COLORS.fetch(event_type.to_s, "text-primary")
    path_data = EVENT_TYPE_ICON_PATHS.fetch(event_type.to_s, EVENT_TYPE_ICON_PATHS["meeting"])

    tag.span(class: "inline-flex shrink-0 #{color_class}", aria: { hidden: true }) do
      event_type_svg(path_data, size_class)
    end
  end

  def event_type_chip(event_type, size: :default)
    icon_size = size == :sm ? :sm : :default

    tag.span(class: "#{category_chip_class(size: size)} inline-flex items-center gap-1") do
      safe_join([ event_type_icon(event_type, size: icon_size), event_type_label(event_type) ])
    end
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

  private

  def event_type_svg(path_data, size_class)
    tag.svg(viewBox: "0 0 24 24", fill: "currentColor", class: size_class) do
      tag.path(d: path_data)
    end
  end
end
