class AddConfigurationToClearTestRun < ActiveRecord::Migration[7.1]
  def change
    add_column :clear_test_runs, :configuration, :jsonb
  end
end
