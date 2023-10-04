# frozen_string_literal: true

class Clears::UsedOperatorResponsiveComponent < ApplicationComponent
  attr_reader :used_operator

  def initialize(used_operator:)
    @used_operator = used_operator
  end
end
