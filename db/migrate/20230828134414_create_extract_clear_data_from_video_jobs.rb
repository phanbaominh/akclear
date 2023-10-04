class CreateExtractClearDataFromVideoJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :extract_clear_data_from_video_jobs do |t|
      t.integer :status
      t.jsonb :data
      t.string :video_url

      t.timestamps
    end
  end
end
