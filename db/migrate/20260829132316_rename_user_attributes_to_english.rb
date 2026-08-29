class RenameUserAttributesToEnglish < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :nombre, :first_name
    rename_column :users, :apellido, :last_name
    rename_column :users, :activo, :active
  end
end
