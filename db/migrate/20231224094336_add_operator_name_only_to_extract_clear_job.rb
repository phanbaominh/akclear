class AddOperatorNameOnlyToExtractClearJob < ActiveRecord::Migration[7.1]
  def change
    add_column :extract_clear_data_from_video_jobs, :operator_name_only, :boolean, default: true, null: false
  end
end
