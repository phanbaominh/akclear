class CreateStages < ActiveRecord::Migration[7.0]
  def change
    create_table :stages do |t|
      t.string :game_id
      t.string :code
      t.integer :zone

      t.timestamps
    end
  end
end
