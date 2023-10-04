# frozen_string_literal: true

class Clears::SummaryComponent < ApplicationComponent
  def post_initialize(clear:)
    @clear = clear
  end
end
