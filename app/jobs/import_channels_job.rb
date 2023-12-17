# frozen_string_literal: true

class ImportChannelsJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :system
  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { 'import_channels_job' }
  )

  def perform
    Clear.where(channel_id: nil).in_batches.each do |clears|
      channel_external_id_to_clears = build_channel_external_ids_to_clears(clears)
      channel_external_ids = channel_external_id_to_clears.keys
      channel_external_id_to_channel = build_channel_external_id_to_channel(channel_external_ids)

      assign_channels_to_clears(channel_external_id_to_channel, channel_external_id_to_clears)
    end
  rescue StandardError => e
    Rails.logger.error("Failed to import channels: #{e.message}")
  end

  private

  def build_channel_external_ids_to_clears(clears)
    video_id_to_clears = clears.group_by do |clear|
      Video.new(clear.link).video_id
    end
    channel_external_id_to_clears = {}
    Yt::Collections::SimpleVideos.new.where(id: video_id_to_clears.keys).each do |video| # rubocop:disable Rails/FindEach
      channel_external_id_to_clears[video.channel_id] = video_id_to_clears[video.id]
    end
    channel_external_id_to_clears
  end

  def build_channel_external_id_to_channel(channel_external_ids)
    existing_channels = Channel.where(external_id: channel_external_ids)
    new_channel_external_ids = channel_external_ids - existing_channels.map(&:external_id)

    channel_id_to_channel_meta = {}
    if new_channel_external_ids.present?
      Yt::Models::ChannelMeta.new(id: new_channel_external_ids).compositions.each do |channel_meta|
        channel_id_to_channel_meta[channel_meta.id] = channel_meta
      end
    end
    new_channel_external_ids = channel_id_to_channel_meta.keys
    (new_channel_external_ids.filter_map do |external_id|
      c = Channel.new(external_id:)
      c.channel_meta = channel_id_to_channel_meta[external_id]

      c.save ? c : Rails.logger.warn("[#{self.class}] Failed to create channel: #{c.errors.full_messages.first}")
    end + existing_channels).index_by(&:external_id)
  end

  def assign_channels_to_clears(channel_external_id_to_channel, channel_external_id_to_clears)
    channel_external_id_to_clears.each do |channel_external_id, clears|
      clears.each do |clear|
        clear.channel = channel_external_id_to_channel[channel_external_id]
        unless clear.save
          Rails.logger.warn "[#{self.class}] Failed to assign channel to #{clear.id}: #{clear.errors.full_messages.first}"
        end
      end
    end
  end
end
