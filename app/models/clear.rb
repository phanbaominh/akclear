class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  include Clear::Likeable
  include StageSpecifiable
  include Youtubeable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :channel, optional: true # TODO: make this non-optional in the future
  has_many :used_operators, dependent: :destroy
  has_one :verification, dependent: :destroy

  scope :unverified, -> { where.missing(:verification) }

  accepts_nested_attributes_for :used_operators, allow_destroy: true

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true
  validates :channel_id, presence: true

  before_validation :assign_channel
  before_save :normalize_link
  after_save :mark_job_as_clear_created

  attr_accessor :job_id, :channel_id

  # VERIFICATION
  def next_unverified
    Clear.unverified.where(created_at: (created_at...)).where.not(id:).order(created_at: :asc).first
  end

  def prev_unverified
    Clear.unverified.where(created_at: (...created_at)).where.not(id:).order(created_at: :desc).first
  end

  def other_unverified
    next_unverified || prev_unverified
  end

  def verified?
    verification.present?
  end

  def accepted_used_operators
    used_operators.select(&:verification_accepted?)
  end

  def declined_used_operators
    used_operators.select(&:verification_declined?)
  end

  #####

  def normalize_link
    return unless link && will_save_change_to_link?

    self.link = Video.new(link).to_url(normalized: true)
  end

  def mark_job_as_clear_created
    return if job_id.blank?

    job = ExtractClearDataFromVideoJob.find_by(id: job_id)
    job&.mark_clear_created! if job&.completed?
  end

  def assign_channel
    return if new_record? && channel.present?
    return unless will_save_change_to_link?

    self.channel = Channel.from(link)

    return unless channel.present? && (channel.new_record? || will_save_change_to_channel_id?)

    channel.save! if channel.new_record?
    self.channel_id = channel.id
  end

  def duplicate_for_stage_ids(stage_ids)
    loaded_used_operators = used_operators.includes(:operator)
    stage_ids.reject { |si| si == stage_id }.compact.map do |stage_id|
      duplicate_clear = dup
      dup_used_operators = loaded_used_operators.map do |used_operator|
        dup_used_operator = used_operator.dup
        dup_used_operator.operator = used_operator.operator
        dup_used_operator
      end
      duplicate_clear.stage_id = stage_id
      duplicate_clear.used_operators = dup_used_operators
      duplicate_clear.channel = channel
      duplicate_clear.job_id = nil
      duplicate_clear
    end.each(&:save)
  end
end
