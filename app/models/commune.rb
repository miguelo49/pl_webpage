class Commune < ApplicationRecord
  belongs_to :region

  has_many :events, dependent: :nullify
  has_many :initiatives, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :region_id }
end
