class AddEventIdToStages < ActiveRecord::Migration[7.0]
  def change
    add_reference :stages, :event, null: false, foreign_key: true # rubocop:disable Rails/NotNullColumn
  end
end
