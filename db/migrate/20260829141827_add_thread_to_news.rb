class AddThreadToNews < ActiveRecord::Migration[7.2]
  def change
    add_reference :news, :thread, null: true, foreign_key: { to_table: :threads }
  end
end
