class Commune < ApplicationRecord
  belongs_to :region

  has_many :events, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :region_id }
end
