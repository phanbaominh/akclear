# frozen_string_literal: true

class Primer::Button::IconComponent < ApplicationComponent
  def post_initialize(icon:, sr_description:)
    @icon = icon
    @sr_description = sr_description
  end
end
