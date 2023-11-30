# frozen_string_literal: true

class Clears::Form::NewOperatorButtonComponent < ApplicationComponent
  attr_reader :squad

  def post_initialize(squad:)
    @squad = squad
  end

  def disabled
    squad.full?
  end

  def selectable_operators
    Operator.where.not(id: squad.operator_ids).i18n.order(:name).pluck(:name, :id)
  end
end
