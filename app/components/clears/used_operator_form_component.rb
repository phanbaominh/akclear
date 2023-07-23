# frozen_string_literal: true

class Clears::UsedOperatorFormComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :used_operator, :submit_text, :method

  def post_initialize(used_operator:, submit_text: nil, method: :post)
    @used_operator = used_operator
    @method = method
    @submit_text = submit_text || I18n.t(:add_operator)
  end

  delegate :operator, :name, :avatar, :max_elite, :max_skill, :max_skill_level, :max_level,
           to: :used_operator

  def form_namespace
    used_operator.operator_id || 'new_operator'
  end

  def presenter_object
    used_operator
  end

  def skill_alt_text
    "#{name}_#{used_operator.skill}"
  end

  def selectable_operators
    Operator.all.order(:name)
  end

  def skill_levels
    levels = max_skill_level.times.map do |i|
      [i + 1, I18n.t('used_operator_form.skill_level', skill_level: i + 1)]
    end
    masteries = (if used_operator.elite == 2
                   3.times.map do |i|
                     [8 + i,
                      I18n.t('used_operator_form.skill_mastery', skill_mastery: i + 1)]
                   end
                 else
                   []
                 end)
    levels + masteries
  end
end
