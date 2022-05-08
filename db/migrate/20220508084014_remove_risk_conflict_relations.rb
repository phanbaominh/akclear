# frozen_string_literal: true

class RemoveRiskConflictRelations < ActiveRecord::Migration[6.1]
  def change
    drop_table :risk_conflict_relations
  end
end
