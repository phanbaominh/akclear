class AddChannelToExtractClearJob < ActiveRecord::Migration[7.1]
  def change
    add_reference :extract_clear_data_from_video_jobs, :channel, foreign_key: true
  end
end
