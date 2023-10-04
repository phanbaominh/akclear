class AddStageIdToExtractClearDataFromVideoJob < ActiveRecord::Migration[7.0]
  def change
    add_reference :extract_clear_data_from_video_jobs, :stage, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
