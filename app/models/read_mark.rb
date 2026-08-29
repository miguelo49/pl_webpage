class ReadMark < ApplicationRecord
  belongs_to :user
  belongs_to :training_material

  validates :user_id, uniqueness: { scope: :training_material_id }
end
