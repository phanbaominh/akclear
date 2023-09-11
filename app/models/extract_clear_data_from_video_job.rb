class ExtractClearDataFromVideoJob < ApplicationRecord
  belongs_to :stage

  include AASM
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3, clear_created: 4 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed
    state :clear_created

    event :start do
      transitions from: :pending, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :mark_clear_created do
      transitions from: :completed, to: :clear_created
    end
  end

  validates :video_url, presence: true
  validate :valid_video

  def video
    @video ||= Video.new(video_url)
  end

  def video_url=(url)
    super url
    video = Video.new(url)
    return unless video.valid?

    self.stage_id = video.stage_id unless stage_id
  end

  def valid_video
    errors.add(:video_url, 'errors.messages.invalid') unless video.valid?
  end

  def clear
    @clear ||= Clear.new(data) if completed?
  end
end
