# frozen_string_literal: true

class Clears::FormComponent < ApplicationComponent
  include Turbo::FramesHelper

  attr_reader :clear

  def post_initialize(clear:)
    @clear = clear
  end

  def selectable_operators
    Operator.all
  end

  def operator_ids
    clear.used_operators.map(&:operator_id)
  end

  def selectable_stages
    Stage.all
  end
end
