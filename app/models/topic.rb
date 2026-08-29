class Topic < ApplicationRecord
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :name) }

  has_many :threads, class_name: "ForumThread", dependent: :restrict_with_error
end
