class AddUrlsAndExternalIdColumnsToChannel < ActiveRecord::Migration[7.0]
  def change
    change_table :channels, bulk: true do |t|
      t.column :external_id, :string
      t.column :thumbnail_url, :string
      t.column :banner_url, :string
      t.remove :url, type: :string
      t.rename :name, :title

      t.index :external_id, unique: true
    end
  end
end
