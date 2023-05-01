# frozen_string_literal: true

class Clears::Form::OperatorCardComponent < ApplicationComponent
  attr_reader :used_operator

  delegate :elite, :skill, :skill_level, :skill_mastery, :level, :operator, to: :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end

  def operator_image_url
    used_operator.operator.avatar
  end

  def operator_skill_image_url
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_skchr_#{operator.game_id.split('_').last}_#{(skill || 0) + 1}.png"
  end

  def operator_name
    used_operator.operator.name
  end

  def used_operator_params
    used_operator.attributes.slice('id', 'skill', 'skill_level', 'skill_mastery', 'level', 'elite', 'operator_id')
  end
end
