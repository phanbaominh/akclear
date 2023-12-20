class AddSkillIconIdsToOperators < ActiveRecord::Migration[7.1]
  def change
    add_column :operators, :skill_icon_ids, :string, array: true, default: []
  end
end
