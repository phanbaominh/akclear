# frozen_string_literal: true

class Channel < ApplicationRecord
  include VideosImportable

  enum :clear_language, en: 0, jp: 1, 'zh-CN': 2, ko: 3

  belongs_to :user, optional: true
  has_many :clears, dependent: :nullify
  validates :external_id, presence: true, uniqueness: true

  def link
    "https://www.youtube.com/channel/#{external_id}"
  end

  def self.from(link)
    video_data = Yt::Video.new(url: link)
    external_id = video_data.channel_id
    from_external_id(external_id)
  rescue Yt::Errors::RequestError
    Rails.logger.warn("Could not find channel using link: #{link}")
    nil
  end

  def self.from_external_id(external_id)
    find_or_initialize_by(external_id:).tap do |c|
      next if c.persisted?

      c.external_id = external_id
      channel_data = Yt::Models::ChannelMeta.new(id: external_id)
      c.channel_meta = channel_data
    end
  end

  def channel_meta=(channel_meta)
    self.title = channel_meta.title
    self.thumbnail_url = channel_meta.thumbnail_url
    self.banner_url = channel_meta.banner_url
    self.uploads_playlist_id = channel_meta.uploads_playlist_id
  end
end
