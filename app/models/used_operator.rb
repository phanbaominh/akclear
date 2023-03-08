class UsedOperator < ApplicationRecord
  belongs_to :operator
  belongs_to :clear
  attribute :need_to_be_destroyed, :boolean

  delegate :avatar, :name, to: :operator
  # TODO: add default values for skill/module
end
