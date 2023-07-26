module Yt
  module Models
    class ChannelBranding < Resource
      has_one :branding_setting
      delegate :banner_url, to: :branding_setting
      delegate :thumbnail_url, to: :branding_setting

      def kind
        'channel'
      end
    end
  end
end
