class UsedOperator < ApplicationRecord
  belongs_to :operator
  belongs_to :clear
  attribute :need_to_be_destroyed, :boolean
end
