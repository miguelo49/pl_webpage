# frozen_string_literal: true

module ChileanRut
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_rut_value
    validates :rut, uniqueness: { case_sensitive: false }, allow_nil: true
    validate :rut_must_be_valid, if: -> { rut.present? }
  end

  class_methods do
    def normalize(raw)
      raw.to_s.upcase.gsub(/[^0-9K]/, "")
    end

    def valid?(raw)
      body = normalize(raw)
      return false unless body.match?(/\A\d{7,8}[0-9K]\z/)

      digits = body[0..-2]
      verifier = body[-1]
      verification_digit(digits) == verifier
    end

    def format(raw)
      body = normalize(raw)
      return raw if body.blank?

      digits = body[0..-2]
      verifier = body[-1]
      "#{digits.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}-#{verifier}"
    end

    def verification_digit(digits)
      sum = digits.reverse.chars.each_with_index.sum do |char, index|
        char.to_i * ((index % 6) + 2)
      end
      remainder = 11 - (sum % 11)

      case remainder
      when 11 then "0"
      when 10 then "K"
      else remainder.to_s
      end
    end
  end

  private

  def normalize_rut_value
    self.rut = self.class.normalize(rut) if rut.present?
  end

  def rut_must_be_valid
    return if self.class.valid?(rut)

    errors.add(:rut, "no es válido")
  end
end
