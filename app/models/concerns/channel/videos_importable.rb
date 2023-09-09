module Channel::VideosImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_videos(spec)
      spec.channels.find_each do |channel|
        channel.import_videos do |video_data|
          spec.satisfy?(video_data)
        end
      end
    end
  end

  def import_videos(&)
    selected_playlist_items = Yt::Playlist.new(id: uploads_playlist_id).playlist_items.select(&)
    selected_playlist_items.each do |playlist_item|
      video = Video.from_id(playlist_item.video_id)
      next unless video.valid?

      ExtractClearDataFromVideoJob.create(video_url: video.to_url)
    end
  end
end
