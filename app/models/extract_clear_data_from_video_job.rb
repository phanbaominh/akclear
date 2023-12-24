# frozen_string_literal: true

class ExtractClearDataFromVideoJob < ApplicationRecord
  include Specifiable
  belongs_to :stage
  belongs_to :channel, optional: true

  STATUSES = [
    PENDING = 'pending',
    STARTED = 'started',
    PROCESSING = 'processing',
    COMPLETED = 'completed',
    FAILED = 'failed',
    CLEAR_CREATED = 'clear_created'
  ].freeze

  include AASM
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3, clear_created: 4, started: 5 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :started
    state :processing
    state :completed
    state :failed
    state :clear_created

    # make sure to use bang version to trigger after_commit
    event :start, after_commit: :run do
      transitions from: %i[pending failed processing started], to: :started
    end

    event :process do
      transitions from: :started, to: :processing
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

  validates :video_url, presence: true, uniqueness: true
  validate :valid_video

  def video
    @video ||= Video.new(video_url)
  end

  def video_url=(video_or_url)
    @video =
      if video_or_url.is_a?(String)
        Video.new(video_or_url)
      else
        video_or_url
      end
    super video.to_url

    # this is for making sure it is only set when creating the job from scratch as querying stage_id from video costs a api call
    return if stage_id || !video.valid?

    self.stage_id = video.stage_id
    self.channel = Channel.find_by(external_id: video.channel_external_id) unless channel
    self.data = { name: video.title }
  end

  def valid_video
    errors.add(:video_url, 'errors.messages.invalid') unless video.valid?
  end

  def clear
    return @clear if defined?(@clear)

    return unless completed?

    @clear ||= Clear.new(data)
    # preload data
    operators = Operator.where(id: @clear.used_operators.map(&:operator_id))
    @clear.used_operators.each { |uo| uo.operator = operators.find { |o| o.id == uo.operator_id } }
    @clear.job_id = id
    @clear
  end

  def run
    return unless started?

    ExtractClearDataFromVideoJobRunner.perform_later(id)
  end
end
