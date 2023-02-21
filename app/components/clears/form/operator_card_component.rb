# frozen_string_literal: true

class Clears::Form::OperatorCardComponent < ApplicationComponent
  def post_initialize(form:)
    @form = form
  end

  def used_operator
    @form.object
  end

  def operator_image_url
    used_operator.operator.avatar
  end

  def operator_name
    used_operator.operator.name
  end

  def tooltip_id
    "operator_#{used_operator.operator_id}"
  end
end
