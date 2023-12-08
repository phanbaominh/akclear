class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Likeable
  include Reportable
  include Squadable
  include StageSpecifiable
  include Youtubeable
  include Duplicatable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :channel, optional: true
  has_one :verification, dependent: :destroy

  scope :unverified, -> { where.missing(:verification) }
  scope :submitted_by, ->(user) { where(submitter_id: user.id) }

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true

  before_save :normalize_link
  after_update -> { verification&.destroy }
  after_save :mark_job_as_clear_created
  after_commit :assign_channel

  # considering separate spec logic from model
  attr_accessor :job_id, :channel_id, :self_only, :verification_status

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

  def preload_operators(with_verification: false)
    return unless persisted?

    nested_associations =
      if with_verification
        %i[operator verification]
      else
        [:operator]
      end

    ActiveRecord::Associations::Preloader.new(
      records: [self],
      associations: [used_operators: nested_associations]
    ).call
    Operator.build_translations_cache(Operator.from_clear_ids([id]))
    self
  end

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
    return if previously_new_record? && channel.present?
    return unless saved_change_to_link?

    Clears::AssignChannelJob.perform_later(id, link)
  end
end
