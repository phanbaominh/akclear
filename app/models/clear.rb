class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :player, class_name: 'User', optional: true
  has_many :used_operators, dependent: :destroy
  accepts_nested_attributes_for :used_operators, allow_destroy: true

  delegate :event?, :stageable, :challenge_mode?, to: :stage, allow_nil: true

  validates :link, presence: true
end
