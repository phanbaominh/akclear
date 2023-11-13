class AddTimestampToLikes < ActiveRecord::Migration[7.0]
  def change
    change_table :likes do |t|
      t.datetime :created_at, null: false
      t.index :created_at, if_not_exists: true
    end
  end
end
