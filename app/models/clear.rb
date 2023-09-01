class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  include Clear::Likeable
  include Clear::Specifiable
  include Youtubeable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :channel, optional: true # TODO: make this non-optional in the future
  has_many :used_operators, dependent: :destroy
  has_one :verification, dependent: :destroy

  accepts_nested_attributes_for :used_operators, allow_destroy: true

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true
  validates :channel_id, presence: true

  before_validation :assign_channel
  before_save :normalize_link
  after_save :assign_channel

  def verified?
    verification.present?
  end

  def normalize_link
    return unless link && will_save_change_to_link?

    self.link = Video.new(link).to_url(normalized: true)
  end

  def assign_channel
    return if new_record? && channel.present?
    return unless will_save_change_to_link?

    self.channel = Channel.from(link)

    return unless channel.present? && (channel.new_record? || will_save_change_to_channel_id?)

    channel.save! if channel.new_record?
    self.channel_id = channel.id
  end
end
