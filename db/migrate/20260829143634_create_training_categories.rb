class CreateTrainingCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :training_categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :training_categories, :name, unique: true
  end
end
