class TrainingCategory < ApplicationRecord
  has_many :training_materials, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
