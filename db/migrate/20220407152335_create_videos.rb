class CreateVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :videos do |t|
      t.string :link
      t.text :description
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :like

      t.timestamps
    end
  end
end
