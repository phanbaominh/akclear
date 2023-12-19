class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.references :user, foreign_key: true
      t.references :clear, foreign_key: true

      t.datetime :created_at, null: false
      t.index :created_at, if_not_exists: true
    end
  end
end
