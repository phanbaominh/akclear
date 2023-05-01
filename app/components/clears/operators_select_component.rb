# frozen_string_literal: true

class Clears::OperatorsSelectComponent < ApplicationComponent
  include Turbo::FramesHelper
  include Turbo::StreamsHelper
  attr_reader :form, :params

  def post_initialize(form:)
    @form = form
  end

  def selectable_operators
    Operator.all
  end
end
