# frozen_string_literal: true

class Clears::UsedOperatorMiniComponent < ApplicationComponent
  delegate :name, :avatar, :skill_image_url, :elite_image_url, :skill, :skill_level, :level, :elite, to: :used_operator
  attr_reader :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end
end
