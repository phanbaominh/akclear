# frozen_string_literal: true

class Clears::UsedOperatorEditMiniComponent < ApplicationComponent
  attr_reader :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end

  def used_operator_params
    used_operator.attributes.slice('id', 'skill', 'skill_level', 'skill_mastery', 'level', 'elite', 'operator_id')
  end
end
