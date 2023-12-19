class CreateUsedOperatorVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :used_operator_verifications do |t|
      t.references :verification, null: false, foreign_key: true
      t.references :used_operator, null: false, foreign_key: true
      t.integer :status
    end
  end
end
