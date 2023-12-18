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
  normalizes :link, with: ->(value) { Video.new(value).to_url(normalized: true) || value }

  validate :valid_link
  validates :name, length: { maximum: 255 }

  after_create :mark_job_as_clear_created
  after_commit :assign_channel, if: :trigger_assign_channel

  # considering separate spec logic from model
  attr_accessor :job_id, :self_only, :trigger_assign_channel

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
    return if (video = Video.new(link)).valid?

    errors.import(video.errors.where(:url).first, attribute: :link)
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
    # only run for admin?, run job at end of day/manually to insert channel info for all pending videos?
    return if previously_new_record? && channel.present?
    return unless saved_change_to_link?

    Clears::AssignChannelJob.perform_later(id, link)
  end
end
