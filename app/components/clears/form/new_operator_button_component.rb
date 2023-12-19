# frozen_string_literal: true

class Clears::Form::NewOperatorButtonComponent < ApplicationComponent
  attr_reader :squad, :create

  def post_initialize(squad:, create: false)
    @squad = squad
    @create = create
  end

  def disabled
    squad.full?
  end

  def selectable_operators
    Operator.where.not(id: squad.operator_ids).i18n.order(:name).pluck(:name, :id)
  end
end
