# frozen_string_literal: true

class Clears::Form::OperatorCardComponent < ApplicationComponent
  def post_initialize(form:)
    @form = form
  end
end
