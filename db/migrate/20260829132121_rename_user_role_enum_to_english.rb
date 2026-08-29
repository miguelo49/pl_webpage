class RenameUserRoleEnumToEnglish < ActiveRecord::Migration[7.2]
  ROLE_MAPPING = {
    0 => "sympathizer",
    1 => "militant",
    2 => "board_member",
    3 => "moderator",
    4 => "technical_admin"
  }.freeze

  def up
    say "User roles are stored as integers; existing data maps to English keys:"
    ROLE_MAPPING.each do |value, name|
      say "  #{value} => #{name}", true
    end
  end

  def down
    say "Reverting to Spanish enum keys in app/models/user.rb if needed."
  end
end
