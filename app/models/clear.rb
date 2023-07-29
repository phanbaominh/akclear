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

  after_save :assign_channel

  def verified?
    verification.present?
  end

  def assign_channel
    return unless saved_change_to_link?

    self.channel = Channel.from(link)

    return unless has_changes_to_save?

    channel.save! if channel.new_record?
    save!
  end
end
