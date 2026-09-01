class AddStatusToEvents < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :status, :integer, default: 1, null: false
  end

  def down
    remove_column :events, :status
  end
end
