# frozen_string_literal: true

module TestRut
  def unique_valid_rut
    body = rand(10_000_000..25_000_000).to_s
    "#{body}#{User.verification_digit(body)}"
  end
end

RSpec.configure do |config|
  config.include TestRut
end
