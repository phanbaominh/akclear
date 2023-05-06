# frozen_string_literal: true

class Clears::UsedOperatorComponent < ApplicationComponent
  delegate :name, :avatar, :skill_image_url, :elite_image_url, to: :presenter
  attr_reader :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end

  def presenter_object
    used_operator
  end
end
