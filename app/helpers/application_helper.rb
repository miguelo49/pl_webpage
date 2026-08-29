module ApplicationHelper
  STATUS_BADGE_VARIANTS = {
    neutral: "bg-gray-100 text-gray-700 ring-1 ring-gray-200",
    pending: "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    progress: "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    approved: "bg-green-50 text-green-800 ring-1 ring-green-200",
    rejected: "bg-red-50 text-red-800 ring-1 ring-red-200",
    info: "bg-sky-50 text-sky-800 ring-1 ring-sky-200"
  }.freeze

  def status_badge_class(variant = :neutral)
    STATUS_BADGE_VARIANTS.fetch(variant, STATUS_BADGE_VARIANTS[:neutral])
  end
end
