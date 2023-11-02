class UsedOperator < ApplicationRecord
  belongs_to :operator
  belongs_to :clear

  has_one :verification, dependent: :destroy, class_name: 'UsedOperatorVerification'

  attribute :need_to_be_destroyed, :boolean

  delegate :name, :avatar, :max_elite, :max_skill, :max_skill_level, :max_level, :has_skills?, to: :operator
  delegate :accepted?, :declined?, :status, to: :verification, prefix: true, allow_nil: true

  after_update -> { verification&.destroy }

  # TODO: add default values for skill/module

  def verified?
    verification.present?
  end

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
