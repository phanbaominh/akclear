class AddNameAndNoteToClearTestRun < ActiveRecord::Migration[7.1]
  def change
    add_column :clear_test_runs, :name, :string
    add_column :clear_test_runs, :note, :text
  end
end
