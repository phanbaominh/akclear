# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  attr_reader :searched_clear

  def post_initialize(searched_clear:)
    @searched_clear = searched_clear
  end

  def initial_operators_ids
    searched_clear.used_operators.map(&:operator_id)
  end

  def operators_select_data
    Operator.first(5).map do |operator|
      {
        value: operator.id.to_s,
        label: operator.name,
        customProperties: {
          avatar: operator.avatar,
          selected: initial_operators_ids.include?(operator.id)
        }
      }
    end.to_json
  end
end
