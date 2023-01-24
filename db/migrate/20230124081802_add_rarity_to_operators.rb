class AddRarityToOperators < ActiveRecord::Migration[7.0]
  def change
    add_column :operators, :rarity, :integer
  end
end
