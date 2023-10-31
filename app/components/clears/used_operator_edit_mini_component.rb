# frozen_string_literal: true

class Clears::UsedOperatorEditMiniComponent < ApplicationComponent
  attr_reader :used_operator

  def post_initialize(used_operator:)
    @used_operator = used_operator
  end

  def used_operator_params
    used_operator.attributes.symbolize_keys.slice(*ClearFilterable::PERSISTED_OPERATORS_ATTRIBUTES)
  end
end
