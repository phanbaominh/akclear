# frozen_string_literal: true

class ClearImage::TestCase < ApplicationRecord
  self.table_name = 'clear_test_cases'

  def self.enabled?
    Rails.env.local?
  end

  def video
    @video ||= Video.new(video_url)
  end

  def clear_image_path
    @clear_image_path ||= Rails.public_path.join('tmp', 'clear_test_cases', "clear_#{id}.jpg")
  end

  belongs_to :clear
end
