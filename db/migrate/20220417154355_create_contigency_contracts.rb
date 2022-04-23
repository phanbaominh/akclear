class CreateContigencyContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contigency_contracts do |t|
      t.string :name
      t.string :logo
      t.integer :number

      t.timestamps
    end
  end
end
