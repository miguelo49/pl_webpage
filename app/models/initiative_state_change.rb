class InitiativeStateChange < ApplicationRecord
  belongs_to :initiative
  belongs_to :user

  enum :previous_status, Initiative.statuses, prefix: :previous
  enum :new_status, Initiative.statuses, prefix: :new

  validates :previous_status, presence: true
  validates :new_status, presence: true
  validates :user, presence: true
end
