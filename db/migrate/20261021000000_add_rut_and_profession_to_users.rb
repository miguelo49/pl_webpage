# frozen_string_literal: true

class AddRutAndProfessionToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true

    add_column :users, :rut, :string
    add_column :users, :profession, :string

    add_index :users, :rut, unique: true, where: "rut IS NOT NULL"
  end
end
