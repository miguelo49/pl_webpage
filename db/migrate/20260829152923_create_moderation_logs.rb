class CreateModerationLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :moderation_logs do |t|
      t.references :moderator, null: false, foreign_key: { to_table: :users }
      t.references :moderatable, polymorphic: true, null: false
      t.string :action, null: false
      t.text :rejection_reason

      t.timestamps
    end

    add_index :moderation_logs, [ :moderatable_type, :moderatable_id, :created_at ], name: "index_moderation_logs_on_moderatable_and_created_at"
  end
end
