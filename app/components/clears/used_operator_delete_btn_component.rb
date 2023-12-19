# frozen_string_literal: true

class Clears::UsedOperatorDeleteBtnComponent < ApplicationComponent
  attr_reader :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end
end
