# frozen_string_literal: true

class AddSympathizerVisibleToThreads < ActiveRecord::Migration[7.2]
  def change
    add_column :threads, :sympathizer_visible, :boolean, null: false, default: true
  end
end
