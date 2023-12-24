# frozen_string_literal: true

class Clears::UsedOperatorDeleteBtnComponent < ApplicationComponent
  attr_reader :used_operator, :icon

  def post_initialize(used_operator:, icon: 'trash')
    @used_operator = used_operator
    @icon = icon
  end
end
