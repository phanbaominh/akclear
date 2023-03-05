# frozen_string_literal: true

class Clears::ListComponent < ApplicationComponent
  include Turbo::FramesHelper
  def post_initialize(clears:)
    @clears = clears
  end

  def stageable_name(clear)
    stageable = clear.stage.stageable
    clear.event? ? stageable.name : t('.main_story')
  end
end
