class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  include Clear::Likeable
  include Youtubeable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :channel, optional: true # TODO: make this non-optional in the future
  has_many :used_operators, dependent: :destroy
  has_one :verification, dependent: :destroy

  accepts_nested_attributes_for :used_operators, allow_destroy: true

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true

  attribute :challenge_mode, :boolean
  attribute :environment, :string
  attribute :stageable_id, :string
  attribute :operator_id, :integer
  attribute :stage_type, :string

  validates :stage_type, inclusion: { in: Stage::STAGEABLE_TYPES }, allow_blank: true

  def environment
    Episode::Environment.new(super) if super
  end

  def stageable
    stageable_id ? GlobalID::Locator.locate(stageable_id) : stage&.stageable
  end

  def stage_id
    stageable.is_a?(Annihilation) ? stageable.stages.first.id : super
  end

  def verified?
    verification.present?
  end

  def challenge_mode=(value)
    if stageable&.challengable?
      super
    else
      super nil
    end
  end

  def environment=(value)
    if stageable&.has_environments?
      super
    else
      super nil
    end
  end

  def reset_spec
    self.stage_id = nil
    self.stageable_id = nil
    self.environment = nil
    self.challenge_mode = nil
  end
end
