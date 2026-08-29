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

  STATUS_BADGE_CLASSES = {
    "idea" => "bg-gray-100 text-gray-700",
    "in_discussion" => "bg-sky-50 text-sky-700",
    "in_development" => "bg-amber-50 text-amber-700",
    "in_review" => "bg-violet-50 text-violet-700",
    "approved" => "bg-green-50 text-green-700",
    "rejected" => "bg-red-50 text-red-700",
    "archived" => "bg-stone-100 text-stone-600"
  }.freeze

  def initiative_status_label(status)
    STATUS_LABELS.fetch(status.to_s, status.to_s.humanize)
  end

  def initiative_status_badge_class(status)
    STATUS_BADGE_CLASSES.fetch(status.to_s, "bg-gray-100 text-gray-700")
  end
end
