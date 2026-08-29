module InitiativesHelper
  STATUS_LABELS = {
    "idea" => "Idea",
    "in_discussion" => "En discusión",
    "in_development" => "En desarrollo",
    "in_review" => "En revisión",
    "approved" => "Aprobada",
    "rejected" => "Rechazada",
    "archived" => "Archivada"
  }.freeze

  STATUS_BADGE_VARIANTS = {
    "idea" => :neutral,
    "in_discussion" => :pending,
    "in_development" => :progress,
    "in_review" => :pending,
    "approved" => :approved,
    "rejected" => :rejected,
    "archived" => :neutral
  }.freeze

  def initiative_status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.humanize)
  end

  def initiative_status_badge_class(status)
    status_badge_class(STATUS_BADGE_VARIANTS.fetch(status.to_s, :neutral))
  end
end
