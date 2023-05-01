# frozen_string_literal: true

class Clears::FiltersComponent < ApplicationComponent
  include Turbo::StreamsHelper
  include Turbo::FramesHelper

  attr_reader :clear_spec

  delegate :operator_ids, to: :clear_spec

  def post_initialize(clear_spec:)
    @clear_spec = clear_spec
  end

  def selectable_operators
    Operator.all
  end
end
