module Yt
  module Models
    # @private
    class Composition < Base
      has_attribute :channel, default: {}
      has_attribute :image, default: {}
      has_attribute :thumbnails, default: {}
      has_attribute :related_playlists, default: {}

      attr_reader :data, :id

      def initialize(options = {})
        @data = options[:data]
        @auth = options[:auth]
        @id = options[:id]
      end

      def banner_url(size = nil)
        [image.fetch('bannerExternalUrl', ''), size].compact.join('=')
      end

      def thumbnail_url(size = :default)
        thumbnails.fetch(size.to_s, {})['url']
      end

      def uploads_playlist_id
        related_playlists['uploads']
      end

      def title 
        channel['title']
      end

      def kind
        'channel'
      end
    end
  end
end
