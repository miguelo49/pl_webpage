class User < ApplicationRecord
  ROLES = %w[sympathizer militant board_member moderator technical_admin].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    sympathizer: 0,
    militant: 1,
    board_member: 2,
    moderator: 3,
    technical_admin: 4
  }, default: :sympathizer

  validates :nombre, presence: true
  validates :apellido, presence: true
end
