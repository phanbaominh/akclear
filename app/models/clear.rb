class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Likeable
  include Reportable
  include Squadable
  include StageSpecifiable
  include Youtubeable
  include Duplicatable
  include Verifiable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :channel, optional: true

  scope :submitted_by, ->(user) { where(submitter_id: user.id) }

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true, length: { maximum: 255 }
  validates :name, length: { maximum: 255 }
  validate :valid_link

  before_save :normalize_link
  after_create :mark_job_as_clear_created
  after_commit :assign_channel

  # considering separate spec logic from model
  attr_accessor :job_id, :self_only

  def submitted_by?(user = Current.user)
    submitter == user
  end

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

  def valid_link
    errors.add(:link, :invalid) unless Video.new(link).valid?
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

  def created_by_trusted_users?
    submitter.verifier? || submitter.admin?
  end

  def assign_channel
    return if previously_new_record? && channel.present?
    return unless saved_change_to_link?

    Clears::AssignChannelJob.perform_later(id, link)
  end
end
