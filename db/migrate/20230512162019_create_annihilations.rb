class CreateAnnihilations < ActiveRecord::Migration[7.0]
  def change
    create_table :annihilations do |t|
      t.string :game_id
      t.string :name

      t.timestamps
    end
  end
end
