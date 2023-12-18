# frozen_string_literal: true

class Clears::LikeComponent < ApplicationComponent
  attr_reader :clear, :disabled, :hover_class

  delegate :liked?, :likes_count, to: :clear

  def post_initialize(clear:, disabled: false, have_hover: true, turbo_id: nil)
    @clear = clear
    @disabled = disabled
    @hover_class = have_hover ? 'px-2 rounded-full ' + ('hover:bg-primary/40' unless disabled).to_s : ''
    @turbo_id = turbo_id
  end

  def turbo_id
    @turbo_id || dom_id(@clear, :like)
  end
end
