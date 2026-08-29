class CreateInitiativeStateChanges < ActiveRecord::Migration[7.2]
  def change
    create_table :initiative_state_changes do |t|
      t.references :initiative, null: false, foreign_key: true
      t.integer :previous_status, null: false
      t.integer :new_status, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :initiative_state_changes, [ :initiative_id, :created_at ]
  end
end
