# frozen_string_literal: true

class ExtractClearDataFromVideoJob < ApplicationRecord
  include Dry::Monads[:result]
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
      transitions from: %i[completed pending failed], to: :clear_created
    end
  end

  validates :video_url, presence: true, uniqueness: true
  validate :valid_video
  before_validation :fetch_data_from_video

  # for importing/exporting
  attribute :channel_external_id, :string
  attribute :stage_game_id, :string

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
  end

  def fetch_data_from_video
    return unless video.valid?

    self.stage_id = video.stage_id unless stage_id || stage
    self.channel = Channel.find_by(external_id: video.channel_external_id) unless channel
    self.data ||= {}
    self.data['name'] = video.title if data['name'].blank?
  end

  def valid_video
    errors.add(:video_url, 'errors.messages.invalid') unless video.valid?
  end

  def clear
    return @clear if defined?(@clear)

    return unless may_mark_clear_created?

    clear_data = {
      stage_id:,
      link: Video.new(video_url).to_url(normalized: true),
      channel_id:,
      name: data&.dig('name')
    }
    used_operators_attributes = data&.dig('used_operators_attributes')
    clear_data.merge!(used_operators_attributes:) if used_operators_attributes.present?

    @clear ||= Clear.new(clear_data)
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

  def extract_from_video
    case Clears::BuildClearFromVideo.call(video, operator_name_only:,
                                                 languages: channel&.clear_languages)
    in Success(clear)
      self.data = {
        stage_id:,
        link: clear.link,
        used_operators_attributes: clear.used_operators.map { |op| op.attributes.compact_blank },
        channel_id:,
        name: data&.dig('name')
      }.with_indifferent_access
    in Failure(error)
      self.data ||= {}
      self.data['error'] = error
    end
  end

  def error?
    data&.dig('error').present?
  end

  def used_operators_attributes
    data&.dig('used_operators_attributes')
  end

  def to_uid(options = {})
    self.channel_external_id = channel&.external_id
    self.stage_game_id = stage&.game_id
    if used_operators_attributes.present?
      self.data['used_operators_attributes'] =
        used_operators_attributes.map(&:compact_blank)
      replace_operator_id_with_game_id
    end
    URI::UID.build(self, options).to_s
  end

  def replace_operator_id_with_game_id
    return if used_operators_attributes.blank?

    operator_id_to_game_id =
      Operator.where(id: used_operators_attributes.pluck('operator_id')).pluck(:id, :game_id).to_h
    used_operators_attributes.each do |uo|
      uo['operator_game_id'] = operator_id_to_game_id[uo.delete('operator_id')]
    end
  end
end
