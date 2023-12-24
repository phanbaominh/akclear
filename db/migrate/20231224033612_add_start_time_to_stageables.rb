class AddStartTimeToStageables < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :start_time, :datetime
  end
end
