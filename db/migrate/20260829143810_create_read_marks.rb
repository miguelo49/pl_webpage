class CreateReadMarks < ActiveRecord::Migration[7.2]
  def change
    create_table :read_marks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :training_material, null: false, foreign_key: true

      t.timestamps
    end

    add_index :read_marks, [ :user_id, :training_material_id ],
              unique: true,
              name: "index_read_marks_on_user_and_training_material"
  end
end
