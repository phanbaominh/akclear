class CreateVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :verifications do |t|
      t.references :verifier, null: false, foreign_key: { to_table: :users }
      t.references :clear, null: false, foreign_key: true

      t.timestamps
    end
  end
end
