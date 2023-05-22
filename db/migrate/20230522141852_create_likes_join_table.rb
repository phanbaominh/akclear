class CreateLikesJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :clears, :users, column_options: { index: true, foreign_key: true }, table_name: :likes
  end
end
