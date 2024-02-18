class RemoveClearLanguageFromChannels < ActiveRecord::Migration[7.1]
  def change
    remove_column :channels, :clear_language, :integer
  end
end
