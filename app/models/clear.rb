class Clear < ApplicationRecord
  include Dry::Monads[:result]
  include Clear::HardTaggable
  belongs_to :submitter, class_name: 'User'
  belongs_to :stage
  belongs_to :player, class_name: 'User'
end
