# frozen_string_literal: true

module Clears
  class AssignChannelJob < ApplicationJob
    queue_as :system

    def perform(clear_id, video_link)
      clear = Clear.find_by(id: clear_id)

      return if clear.blank?

      channel = Channel.from(video_link)
      clear.channel = channel

      return unless channel.present? && (channel.new_record? || clear.will_save_change_to_channel_id?)

      channel.save! if channel.new_record?
      clear.channel_id = channel.id
      return if clear.save

      Rails.logger.error("Could not assign channel to clear: #{clear.errors.full_messages.join(', ')}")
    end
  end
end
