# frozen_string_literal: true

seed_file = Rails.root.join("db/seeds/#{Rails.env}.rb")

if seed_file.exist?
  load seed_file
else
  warn "No seed file for #{Rails.env} (#{seed_file})"
end
