module AdminHelper
  ROLE_LABELS = {
    "sympathizer" => "Simpatizante",
    "militant" => "Militante",
    "board_member" => "Directiva",
    "moderator" => "Moderador",
    "technical_admin" => "Admin técnico"
  }.freeze

  def user_role_label(role)
    ROLE_LABELS.fetch(role.to_s, role.to_s.humanize)
  end

  def admin_nav_class(path)
    base = "rounded-full px-3 py-1.5 text-sm font-medium"
    current_page?(path) ? "#{base} bg-blue-600 text-white" : "#{base} bg-white text-gray-600 ring-1 ring-gray-200"
  end
end
