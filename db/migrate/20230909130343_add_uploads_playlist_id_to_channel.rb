class AddUploadsPlaylistIdToChannel < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :uploads_playlist_id, :string
  end
end
