class CreateClearTestRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :clear_test_runs do |t|
      t.bigint :test_case_ids, array: true
      t.jsonb :data
    end
  end
end
