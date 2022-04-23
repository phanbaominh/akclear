class CreateRiskConflictRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :risk_conflict_relations do |t|
      t.references :risk, null: false, foreign_key: true
      t.references :conflicted_risk, null: false, foreign_key: { to_table: 'risks' }
      t.integer :kind

      t.timestamps
    end
  end
end
