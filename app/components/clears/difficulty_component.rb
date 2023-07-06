# frozen_string_literal: true

class Clears::DifficultyComponent < ApplicationComponent
  attr_reader :clear

  def post_initialize(clear:)
    @clear = clear
  end
end
