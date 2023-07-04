# frozen_string_literal: true

class Clears::FormComponent < ApplicationComponent
  include Turbo::StreamsHelper
  include Turbo::FramesHelper

  renders_one :header
  renders_one :footer

  attr_reader :clear_spec, :new_form

  delegate :operator_ids, to: :clear_spec

  def post_initialize(clear_spec:, new_form: false)
    @clear_spec = clear_spec
    @new_form = new_form
  end

  def selectable_operators
    Operator.all
  end
end
