# frozen_string_literal: true

class Clears::Form::NewOperatorButtonComponent < ApplicationComponent
  attr_reader :disabled

  def post_initialize(disabled: false)
    @disabled = disabled
  end
end
