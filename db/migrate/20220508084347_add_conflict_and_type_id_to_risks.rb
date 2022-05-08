class AddConflictAndTypeIdToRisks < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :risks, bulk: true do |t|
        t.integer :conflict_id
        t.integer :type_id
      end
    end
  end
end
