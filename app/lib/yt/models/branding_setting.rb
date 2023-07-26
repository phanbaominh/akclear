module Yt
  module Models
    # @private
    class BrandingSetting < Base
      attr_reader :data

      def initialize(options = {})
        @data = options[:data]
        @auth = options[:auth]
      end

      has_attribute :channel, default: {}
      has_attribute :image, default: {}
      has_attribute :thumbnails, default: {}

      def banner_url(size = nil)
        [image.fetch('bannerExternalUrl', ''), size].compact.join('=')
      end

      def thumbnail_url(size = :default)
        thumbnails.fetch(size.to_s, {})['url']
      end

      def kind
        'channel'
      end
    end
  end
end
