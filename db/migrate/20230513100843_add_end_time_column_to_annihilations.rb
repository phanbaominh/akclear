class AddEndTimeColumnToAnnihilations < ActiveRecord::Migration[7.0]
  def change
    add_column :annihilations, :end_time, :datetime
  end
end
