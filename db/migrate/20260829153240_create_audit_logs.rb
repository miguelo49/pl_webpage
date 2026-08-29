class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :auditable, polymorphic: true, null: false
      t.string :action, null: false
      t.text :change_details

      t.timestamps
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id, :created_at ]
  end
end
