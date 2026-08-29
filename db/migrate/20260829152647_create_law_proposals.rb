class CreateLawProposals < ActiveRecord::Migration[7.2]
  def change
    create_table :law_proposals do |t|
      t.string :name, null: false
      t.text :problem, null: false
      t.text :rationale, null: false
      t.text :objective, null: false
      t.text :current_text, null: false
      t.references :user, null: false, foreign_key: true
      t.references :commune, null: false, foreign_key: true
      t.string :category, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :law_proposals, :status
    add_index :law_proposals, :category
  end
end
