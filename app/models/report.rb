class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true

  validates :reason, presence: true
  validates :user, presence: true
  validates :reportable, presence: true
end
