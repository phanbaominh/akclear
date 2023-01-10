class CreateOperators < ActiveRecord::Migration[7.0]
  def change
    create_table :operators do |t|
      t.string :name

      t.timestamps
    end
  end
end
