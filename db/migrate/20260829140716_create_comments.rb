class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false
      t.references :parent, foreign_key: { to_table: :comments }
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
