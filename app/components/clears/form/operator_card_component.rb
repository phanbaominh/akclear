# frozen_string_literal: true

class Clears::Form::OperatorCardComponent < ApplicationComponent
  attr_reader :used_operator

  delegate :elite, :skill, :skill_level, :skill_mastery, :level, :operator, to: :used_operator
  delegate :name, :avatar, :skill_image_url, :elite_image_url, to: :presenter

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end

  def presenter_object
    used_operator
  end

  def used_operator_params
    used_operator.attributes.slice('id', 'skill', 'skill_level', 'skill_mastery', 'level', 'elite', 'operator_id')
  end
end
