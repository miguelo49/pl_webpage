# frozen_string_literal: true

class AddSympathizerVisibleToTrainingMaterials < ActiveRecord::Migration[7.2]
  def change
    add_column :training_materials, :sympathizer_visible, :boolean, null: false, default: true
  end
end
