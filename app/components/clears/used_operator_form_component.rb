# frozen_string_literal: true

class Clears::UsedOperatorFormComponent < ApplicationComponent
  attr_reader :used_operator, :submit_text, :method

  def post_initialize(used_operator:, submit_text: nil, method: :post)
    @used_operator = used_operator
    @method = method
    @submit_text = submit_text || I18n.t(:add_operator)
  end

  delegate :operator, :name, :avatar, :max_elite, :max_skill, :max_skill_level, :max_level,
           to: :used_operator
  delegate :elite, :skill, to: :used_operator, prefix: true

  def presenter_object
    used_operator
  end

  def skill_alt_text
    "#{name}_#{used_operator_skill}"
  end

  # Hacky way to get for attribute of label, consider using simple form custom components
  def label_for(form, field, value)
    "#{form.object_name.tr('[', '_').tr(']', '')}_#{field}_#{value}"
  end
end
