class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, {
    registered: 0,
    confirmed: 1,
    cancelled: 2
  }, default: :registered

  validates :user_id, uniqueness: { scope: :event_id }
  validate :capacity_available, if: :requires_capacity_check?

  scope :active, -> { where(status: [ statuses[:registered], statuses[:confirmed] ]) }

  def self.policy_class
    AttendancePolicy
  end

  def occupying_spot?
    registered? || confirmed?
  end

  private

  def requires_capacity_check?
    return false unless occupying_spot?
    return true if new_record?

    will_save_change_to_status? && status_in_database == "cancelled"
  end

  def capacity_available
    return unless event
    return if event.unlimited_capacity?

    reserved_spots = event.reserved_spots_excluding(self)
    return if reserved_spots < event.capacity

    errors.add(:base, "No quedan cupos disponibles")
  end
end
