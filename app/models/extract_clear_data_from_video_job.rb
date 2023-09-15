class ExtractClearDataFromVideoJob < ApplicationRecord
  belongs_to :stage

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
      transitions from: :pending, to: :started
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

  validates :video_url, presence: true
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

    self.stage_id = video.stage_id unless stage_id
  end

  def valid_video
    errors.add(:video_url, 'errors.messages.invalid') unless video.valid?
  end

  def clear
    return @clear if defined?(@clear)

    return unless completed?

    @clear ||= Clear.new(data)
    operators = Operator.where(id: @clear.used_operators.map(&:operator_id))
    @clear.used_operators.each { |uo| uo.operator = operators.find { |o| o.id == uo.operator_id } }
    @clear
  end

  def run
    return unless started?

    ExtractClearDataFromVideoJobRunner.perform_later(id)
  end
end
