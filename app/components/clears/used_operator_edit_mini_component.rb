# frozen_string_literal: true

class Clears::UsedOperatorEditMiniComponent < Clears::UsedOperatorMiniComponent
  def used_operator_params
    used_operator.attributes.symbolize_keys.slice(*UsedOperatorsSession::PERSISTED_OPERATORS_ATTRIBUTES)
  end
end
