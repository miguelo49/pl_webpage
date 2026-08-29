class CreateNews < ActiveRecord::Migration[7.2]
  def change
    create_table :news do |t|
      t.string :title, null: false
      t.text :summary, null: false
      t.text :body, null: false
      t.integer :category, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :published_at
      t.integer :status, null: false, default: 1

      t.timestamps
    end
  end
end
