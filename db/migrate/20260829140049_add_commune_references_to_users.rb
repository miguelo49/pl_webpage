class AddCommuneReferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :residence_commune, foreign_key: { to_table: :communes }, null: true
    add_reference :users, :work_commune, foreign_key: { to_table: :communes }, null: true
    add_reference :users, :study_commune, foreign_key: { to_table: :communes }, null: true
  end
end
