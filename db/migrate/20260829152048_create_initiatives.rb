class CreateInitiatives < ActiveRecord::Migration[7.2]
  def change
    create_table :initiatives do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.text :problem, null: false
      t.text :proposal, null: false
      t.references :user, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true
      t.string :category, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :initiatives, :status
    add_index :initiatives, :category
  end
end
