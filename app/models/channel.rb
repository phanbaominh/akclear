# frozen_string_literal: true

class Channel < ApplicationRecord
  belongs_to :user, optional: true

  def self.from(link)
    video_data = Yt::Video.new(url: link)
    external_id = video_data.channel_id
    Channel.find_or_initialize_by(external_id:).tap do |c|
      next if c.persisted?

      c.title = video_data.channel_title
      c.external_id = external_id
      channel_data = Yt::Models::ChannelBranding.new(id: external_id)
      c.thumbnail_url = channel_data.thumbnail_url
      c.banner_url = channel_data.banner_url
    end
  rescue Yt::Errors::RequestError
    Rails.logger.warn("Could not find channel using link: #{link}")
    nil
  end
end
