# frozen_string_literal: true

class Clears::LikeComponent < ApplicationComponent
  attr_reader :clear, :disabled

  delegate :liked?, :likes_count, to: :clear

  def post_initialize(clear:, disabled: false)
    @clear = clear
    @disabled = disabled
  end
end
