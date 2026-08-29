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
    secondary_nav_class(path)
  end
end
