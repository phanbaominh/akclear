class AddUniqueIndexToRiskConflictRelations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :risk_conflict_relations, %i[risk_id conflicted_risk_id], unique: true, algorithm: :concurrently
  end
end
