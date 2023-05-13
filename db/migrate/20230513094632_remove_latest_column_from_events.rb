class RemoveLatestColumnFromEvents < ActiveRecord::Migration[7.0]
  def change
    remove_column :events, :latest, :boolean
  end
end
