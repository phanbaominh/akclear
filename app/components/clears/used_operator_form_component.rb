# frozen_string_literal: true

class Clears::UsedOperatorFormComponent < ApplicationComponent
  include Turbo::FramesHelper
  attr_reader :used_operator, :submit_text, :method, :prefix_namespace

  def post_initialize(used_operator:, submit_text: nil, method: :post, prefix_namespace: nil)
    @used_operator = used_operator
    @method = method
    @prefix_namespace = prefix_namespace
    @submit_text = submit_text || I18n.t(:add_operator)
  end

  delegate :operator, :name, :avatar, :max_elite, :max_skill, :max_skill_level, :max_level,
           to: :used_operator

  def edit_form?
    method == :patch
  end

  def form_namespace
    [prefix_namespace, used_operator.operator_id || 'new_operator'].compact.join('_')
  end

  def presenter_object
    used_operator
  end

  def skill_alt_text
    "#{name}_#{used_operator.skill}"
  end

  def selectable_operators
    already_in_squad = used_operator.squad.operator_ids - [used_operator.operator_id]
    Operator.where.not(id: already_in_squad).i18n.order(:name).pluck(:name, :id)
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
