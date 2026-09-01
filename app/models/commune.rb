class Commune < ApplicationRecord
  TERRITORY_REGION_NAME = "Región de Valparaíso"

  belongs_to :region

  has_many :events, dependent: :nullify
  has_many :initiatives, dependent: :restrict_with_error
  has_many :law_proposals, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :region_id }

  scope :in_territory, -> {
    joins(:region).where(regions: { name: TERRITORY_REGION_NAME }).order(:name)
  }
end
