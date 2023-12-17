# frozen_string_literal: true

class Channel < ApplicationRecord
  include VideosImportable

  belongs_to :user, optional: true
  has_many :clears, dependent: :nullify
  validates :external_id, presence: true, uniqueness: true

  def link
    "https://www.youtube.com/channel/#{external_id}"
  end

  def self.from(link)
    video_data = Yt::Video.new(url: link)
    external_id = video_data.channel_id
    Channel.find_or_initialize_by(external_id:).tap do |c|
      next if c.persisted?

      c.title = video_data.channel_title
      c.external_id = external_id
      channel_data = Yt::Models::ChannelMeta.new(id: external_id)
      c.thumbnail_url = channel_data.thumbnail_url
      c.banner_url = channel_data.banner_url
      c.uploads_playlist_id = channel_data.uploads_playlist_id
    end
  rescue Yt::Errors::RequestError
    Rails.logger.warn("Could not find channel using link: #{link}")
    nil
  end
end
