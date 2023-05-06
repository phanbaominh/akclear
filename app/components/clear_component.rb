# frozen_string_literal: true

class ClearComponent < ApplicationComponent
  attr_reader :clear

  def post_initialize(clear:)
    @clear = clear
  end

  def likes_count
    50
  end

  def liked?
    true
  end
end
