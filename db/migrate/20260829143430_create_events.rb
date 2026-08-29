class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :location
      t.datetime :starts_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :starts_at
  end
end
