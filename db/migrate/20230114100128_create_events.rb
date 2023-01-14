class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :game_id
      t.boolean :latest

      t.timestamps
    end
  end
end
