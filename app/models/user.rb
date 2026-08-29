class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    simpatizante: 0,
    militante: 1,
    directiva: 2,
    moderador: 3,
    admin_tecnico: 4
  }, default: :simpatizante

  validates :nombre, presence: true
  validates :apellido, presence: true
end
