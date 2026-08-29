class Region < ApplicationRecord
  has_many :communes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
