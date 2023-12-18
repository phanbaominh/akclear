class AddUniqueIndexToLinkStageIdClears < ActiveRecord::Migration[7.1]
  def change
    add_index :clears, %i[link stage_id], unique: true
  end
end
