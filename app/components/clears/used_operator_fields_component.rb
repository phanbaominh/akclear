# frozen_string_literal: true

class Clears::UsedOperatorFieldsComponent < ApplicationComponent
  attr_reader :form

  def post_initialize(form:)
    @form = form
  end
end
