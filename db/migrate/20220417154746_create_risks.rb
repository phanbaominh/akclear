class CreateRisks < ActiveRecord::Migration[6.1]
  def change
    create_table :risks do |t|
      t.string :description
      t.string :icon
      t.integer :level
      t.references :contingency_contract, null: false, foreign_key: true

      t.timestamps
    end
  end
end
