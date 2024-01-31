# frozen_string_literal: true

class ClearImage::TestCase < ApplicationRecord
  self.table_name = 'clear_test_cases'

  def self.enabled?
    Rails.env.local?
  end

  def video
    @video ||= Video.new(video_url)
  end

  belongs_to :clear
end
