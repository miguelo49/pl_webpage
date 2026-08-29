class CreateThreads < ActiveRecord::Migration[7.2]
  def change
    create_table :threads do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :topic, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
