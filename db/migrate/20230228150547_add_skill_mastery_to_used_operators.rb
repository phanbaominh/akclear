class AddSkillMasteryToUsedOperators < ActiveRecord::Migration[7.0]
  def change
    add_column :used_operators, :skill_mastery, :integer
  end
end
