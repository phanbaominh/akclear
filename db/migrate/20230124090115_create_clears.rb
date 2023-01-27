class CreateClears < ActiveRecord::Migration[7.0]
  def change
    create_table :clears do |t|
      t.references :submitter, null: false, foreign_key: { to_table: :users }
      t.string :link
      t.references :stage, null: false, foreign_key: true
      t.string :player_name
      t.references :player, foreign_key: { to_table: :users }
      t.string :name

      t.timestamps
    end
  end
end
