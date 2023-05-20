class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  include Youtubeable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :player, class_name: 'User', optional: true
  has_many :used_operators, dependent: :destroy
  accepts_nested_attributes_for :used_operators, allow_destroy: true

  delegate :event?, to: :stage, allow_nil: true

  validates :link, presence: true

  attribute :challenge_mode, :boolean
  attribute :stageable_id, :string
  attribute :operator_id, :integer

  def stageable
    stage ? stage.stageable : GlobalID::Locator.locate(stageable_id)
  end

  def stage_id
    stageable.is_a?(Annihilation) ? stageable.stages.first.id : super
  end
end
