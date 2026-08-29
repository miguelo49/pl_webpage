class CreateLawProposalVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :law_proposal_versions do |t|
      t.references :law_proposal, null: false, foreign_key: true
      t.text :text, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :law_proposal_versions, [ :law_proposal_id, :created_at ]
  end
end
