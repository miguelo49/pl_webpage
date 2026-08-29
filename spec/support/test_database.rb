# frozen_string_literal: true

module TestDatabase
  EXCLUDED_TABLES = %w[schema_migrations ar_internal_metadata].freeze

  module_function

  def truncate_all!
    ActiveRecord::Base.connection.tables.each do |table|
      next if EXCLUDED_TABLES.include?(table)

      ActiveRecord::Base.connection.execute("TRUNCATE TABLE \"#{table}\" RESTART IDENTITY CASCADE")
    end
  end
end
