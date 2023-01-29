class CreateUsedOperators < ActiveRecord::Migration[7.0]
  def change
    create_table :used_operators do |t|
      t.references :operator, null: false, foreign_key: true
      t.references :clear, null: false, foreign_key: true
      t.integer :skill
      t.integer :skill_level
      t.integer :used_module
      t.integer :module_level
      t.integer :level
      t.integer :elite

      t.timestamps
    end
  end
end
