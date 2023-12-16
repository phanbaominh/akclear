module Channel::VideosImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_videos_from_channels(spec)
      spec.channels.find_each do |channel|
        channel.import_videos(spec)
        spec.reset
      end
    end
  end

  def import_videos(spec)
    selected_playlist_items =
      Yt::Playlist.new(id: uploads_playlist_id).playlist_items.each.with_object([]) do |video_data, selected_videos|
        selected_videos << video_data if spec.satisfy?(video_data)
        break selected_videos if spec.stop?
      end
    selected_playlist_items.map do |playlist_item|
      video = Video.from_id(playlist_item.video_id) \
      # reuse to avoid calling API to get video
      video.metadata = playlist_item

      # need to assign channel first so that it is available in video_url=
      ExtractClearDataFromVideoJob.new(channel: self, video_url: video)
    end.map(&:save)
  end
end
