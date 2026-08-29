class RefactorEvents < ActiveRecord::Migration[7.2]
  def change
    remove_index :events, column: :starts_at, if_exists: true
    rename_column :events, :starts_at, :start_at
    add_index :events, :start_at

    remove_foreign_key :events, :users
    rename_column :events, :user_id, :organizer_id
    add_foreign_key :events, :users, column: :organizer_id

    add_column :events, :end_at, :datetime
    add_column :events, :event_type, :integer, null: false, default: 0
    add_reference :events, :commune, null: true, foreign_key: true
    add_column :events, :capacity, :integer
  end
end
