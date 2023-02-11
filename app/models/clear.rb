class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  include Clear::Squadable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :player, class_name: 'User'
  has_many :used_operators, dependent: :destroy
  accepts_nested_attributes_for :used_operators, allow_destroy: true
end
