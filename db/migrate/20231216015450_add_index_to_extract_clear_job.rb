class AddIndexToExtractClearJob < ActiveRecord::Migration[7.1]
  def change
    add_index :extract_clear_data_from_video_jobs, :video_url, unique: true
  end
end
