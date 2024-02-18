class CreateClearTestCases < ActiveRecord::Migration[7.1]
  def change
    create_table :clear_test_cases do |t|
      t.references :clear, null: false, foreign_key: true
      t.string :video_url
      t.jsonb :used_operators_data
    end
  end
end
