class AddStageableColumnsToStages < ActiveRecord::Migration[7.0]
  def change
    add_reference :stages, :stageable, null: false, polymorphic: true # rubocop:disable Rails/NotNullColumn
  end
end
