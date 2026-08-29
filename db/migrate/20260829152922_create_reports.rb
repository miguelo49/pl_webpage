class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reportable, polymorphic: true, null: false
      t.text :reason, null: false

      t.timestamps
    end

    add_index :reports, [ :reportable_type, :reportable_id ]
    add_index :reports, [ :user_id, :reportable_type, :reportable_id ]
  end
end
