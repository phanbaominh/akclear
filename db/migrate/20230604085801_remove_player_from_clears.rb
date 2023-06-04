class RemovePlayerFromClears < ActiveRecord::Migration[7.0]
  def change
    remove_reference :clears, :player, foreign_key: { to_table: :users }
    remove_column :clears, :player_name, :string
  end
end
