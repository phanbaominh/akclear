# frozen_string_literal: true

class Clears::UsedOperatorComponent < ApplicationComponent
  delegate :name, :avatar, :skill_image_url, :elite_image_url, :skill, :skill_level, :level, :elite, to: :used_operator
  attr_reader :used_operator, :editable

  def post_initialize(used_operator:, editable: true)
    @used_operator = used_operator
    @editable = editable
  end

  def used_operator_params
    used_operator.attributes.symbolize_keys.slice(*ClearFilterable::PERSISTED_OPERATORS_ATTRIBUTES)
  end

  def declined?
    !used_operator.changed? && used_operator.verification_declined?
  end
end
