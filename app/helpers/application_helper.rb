module ApplicationHelper
  APP_NAME = "Partido Liberal"

  USER_ROLE_LABELS = {
    "sympathizer" => "Simpatizante",
    "militant" => "Militante",
    "board_member" => "Directiva",
    "moderator" => "Moderador",
    "technical_admin" => "Admin técnico"
  }.freeze

  STATUS_BADGE_VARIANTS = {
    neutral: "bg-gray-100 text-gray-700 ring-1 ring-gray-200",
    pending: "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    progress: "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    approved: "bg-green-50 text-green-800 ring-1 ring-green-200",
    rejected: "bg-red-50 text-red-800 ring-1 ring-red-200",
    info: "bg-sky-50 text-sky-800 ring-1 ring-sky-200"
  }.freeze

  def app_name
    APP_NAME
  end

  def liberal_section_title(name, plural: false)
    "#{name} #{plural ? 'Liberales' : 'Liberal'}"
  end

  def status_badge_class(variant = :neutral)
    STATUS_BADGE_VARIANTS.fetch(variant, STATUS_BADGE_VARIANTS[:neutral])
  end

  def user_role_label(role)
    USER_ROLE_LABELS.fetch(role.to_s, role.to_s.humanize)
  end

  def user_role_badge_class(_role = nil)
    status_badge_class(:neutral)
  end

  AVATAR_SIZE_CLASSES = {
    sm: "h-7 w-7 text-[10px]",
    md: "h-9 w-9 text-xs",
    lg: "h-12 w-12 text-sm"
  }.freeze

  def user_initials(user)
    parts = [ user.first_name, user.last_name ].compact_blank
    return "?" if parts.empty?

    parts.map { |name| name[0] }.join.upcase
  end

  def user_avatar(user, size: :md)
    size_class = AVATAR_SIZE_CLASSES.fetch(size)
    base_class = "inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full font-brand font-semibold #{size_class}"

    if user.avatar.attached? && user.avatar.variable?
      image_tag user.avatar.variant(resize_to_fill: avatar_pixel_size(size)),
            class: "#{base_class} object-cover",
            alt: user.first_name
    else
      tag.div(user_initials(user), class: "#{base_class} bg-gradient-to-br from-primary to-secondary text-white")
    end
  end

  def relative_time_ago(time)
    "hace #{time_ago_in_words(time)}"
  end

  private

  def avatar_pixel_size(size)
    case size
    when :sm then [ 28, 28 ]
    when :lg then [ 48, 48 ]
    else [ 36, 36 ]
    end
  end
end
