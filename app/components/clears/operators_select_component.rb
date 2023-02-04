# frozen_string_literal: true

class Clears::OperatorsSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  def post_initialize(clear:, form:)
    @form = form
    @clear = clear
  end
end
