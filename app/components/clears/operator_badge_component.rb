# frozen_string_literal: true

class Clears::OperatorBadgeComponent < ApplicationComponent
  def post_initialize(operator:)
    @operator = operator
  end
end
