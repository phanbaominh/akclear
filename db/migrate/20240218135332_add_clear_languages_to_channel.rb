class AddClearLanguagesToChannel < ActiveRecord::Migration[7.1]
  def change
    add_column :channels, :clear_languages, :string, array: true
  end
end
