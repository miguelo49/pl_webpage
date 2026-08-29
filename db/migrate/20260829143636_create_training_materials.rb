class CreateTrainingMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :training_materials do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :author, null: false
      t.date :date, null: false
      t.references :training_category, null: false, foreign_key: true
      t.string :tags, array: true, default: [], null: false

      t.timestamps
    end
  end
end
