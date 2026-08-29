class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :description, presence: true
  validates :starts_at, presence: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
end
