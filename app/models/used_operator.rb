class UsedOperator < ApplicationRecord
  belongs_to :operator
  belongs_to :clear
  attribute :need_to_be_destroyed, :boolean

  delegate :name, :avatar, :max_elite, :max_skill, :max_skill_level, :max_level, to: :operator

  # TODO: add default values for skill/module

  def max_level
    operator.max_level(elite:)
  end

  def max_skill_level
    operator.max_skill_level(elite:)
  end

  def max_skill
    operator.max_skill(elite:)
  end
end
