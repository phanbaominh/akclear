class AddGameIdToOperators < ActiveRecord::Migration[7.0]
  def change
    add_column :operators, :game_id, :string
  end
end
