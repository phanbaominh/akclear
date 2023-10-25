# frozen_string_literal: true

class ClearComponent < ApplicationComponent
  attr_reader :clear

  def post_initialize(clear:)
    @clear = clear
  end

  delegate :verification, to: :clear
end
