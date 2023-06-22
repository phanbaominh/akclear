class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.string :name
      t.string :url
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
