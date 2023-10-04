# frozen_string_literal: true

class Clears::UsedOperatorMiniComponent < ApplicationComponent
  delegate :name, :avatar, :skill_image_url, :elite_image_url, :skill, :skill_level, :level, :elite, to: :used_operator
  attr_reader :used_operator, :editable

  def post_initialize(used_operator:, editable: true)
    @used_operator = used_operator
    @editable = editable
  end

  def used_operator_params
    used_operator.attributes.slice('id', 'skill', 'skill_level', 'skill_mastery', 'level', 'elite', 'operator_id')
  end
end
