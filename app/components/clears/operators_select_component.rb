# frozen_string_literal: true

class Clears::OperatorsSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  include Turbo::StreamsHelper
  def post_initialize(clear:, form:)
    @form = form
    @clear = clear
  end

  def operators_select_data
    Operator.all.map do |operator|
      {
        value: operator.id,
        label: operator.name,
        customProperties: {
          avatar: operator.avatar
        }
      }
    end.to_json
  end
end
