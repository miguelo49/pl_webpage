class Commune < ApplicationRecord
  belongs_to :region

  validates :name, presence: true, uniqueness: { scope: :region_id }
end
