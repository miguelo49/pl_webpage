class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  belongs_to :commune, optional: true

  has_many :attendances, dependent: :destroy

  enum :event_type, {
    meeting: 0,
    assembly: 1,
    talk: 2,
    course: 3,
    local_activity: 4,
    national_event: 5,
    regional_event: 6,
    online: 7
  }

  validates :title, presence: true
  validates :description, presence: true
  validates :event_type, presence: true
  validates :start_at, presence: true
  validates :organizer, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :end_at_after_start_at

  scope :upcoming, -> { where("start_at >= ?", Time.current).order(:start_at) }

  scope :by_commune, ->(commune_id) {
    commune_id.present? ? where(commune_id: commune_id) : all
  }

  scope :by_event_type, ->(event_type) {
    event_type.present? && event_types.key?(event_type) ? where(event_type: event_type) : all
  }

  def to_ics
    lines = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Partido Liberal//Events//ES",
      "CALSCALE:GREGORIAN",
      "METHOD:PUBLISH",
      "BEGIN:VEVENT",
      "UID:event-#{id}@partido-liberal",
      "DTSTAMP:#{ics_timestamp(Time.current)}",
      "DTSTART:#{ics_timestamp(start_at)}",
      "DTEND:#{ics_timestamp(end_at || start_at + 1.hour)}",
      "SUMMARY:#{ics_escape(title)}",
      "DESCRIPTION:#{ics_escape(description)}"
    ]
    lines << "LOCATION:#{ics_escape(location)}" if location.present?
    lines += [ "END:VEVENT", "END:VCALENDAR" ]
    lines.join("\r\n")
  end

  def self.policy_class
    EventPolicy
  end

  def unlimited_capacity?
    capacity.nil?
  end

  def reserved_spots
    attendances.active.count
  end

  def reserved_spots_excluding(attendance = nil)
    scope = attendances.active
    scope = scope.where.not(id: attendance.id) if attendance&.persisted?
    scope.count
  end

  def remaining_capacity
    return nil if unlimited_capacity?

    [ capacity - reserved_spots, 0 ].max
  end

  def full?
    !unlimited_capacity? && remaining_capacity.zero?
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?
    return if end_at >= start_at

    errors.add(:end_at, "must be after the start time")
  end

  def ics_timestamp(time)
    time.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def ics_escape(value)
    value.to_s.gsub("\\", "\\\\").gsub(";", "\\;").gsub(",", "\\,").gsub("\n", "\\n")
  end
end
