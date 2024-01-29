class AddClearLanguageToChannels < ActiveRecord::Migration[7.1]
  def change
    add_column :channels, :clear_language, :integer
  end
end
