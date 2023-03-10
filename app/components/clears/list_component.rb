# frozen_string_literal: true

class Clears::ListComponent < ApplicationComponent
  include Turbo::FramesHelper
  include Pagy::Frontend
  def post_initialize(clears:, pagy:)
    @clears = clears
    @pagy = pagy
  end

  def stageable_name(clear)
    stageable = clear.stage.stageable
    clear.event? ? stageable.name : t('.main_story')
  end
end
