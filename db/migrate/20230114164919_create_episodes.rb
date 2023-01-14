class CreateEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :episodes do |t|
      t.string :name
      t.integer :number
      t.string :game_id
      t.boolean :latest, default: false

      t.timestamps
    end
  end
end
