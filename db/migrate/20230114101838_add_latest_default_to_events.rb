class AddLatestDefaultToEvents < ActiveRecord::Migration[7.0]
  def change
    change_column_default :events, :latest, from: nil, to: false
  end
end
