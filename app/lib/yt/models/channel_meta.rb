module Yt
  module Models
    class ChannelMeta < Resource
      has_one :composition
      delegate :banner_url, :uploads_playlist_id, :thumbnail_url, :title, to: :composition

      def kind
        'channel'
      end
    end
  end
end
