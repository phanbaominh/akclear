class AddSkillGameIdsToOperator < ActiveRecord::Migration[7.0]
  def change
    add_column :operators, :skill_game_ids, :string, array: true
  end
end
