# frozen_string_literal: true

class Clears::Form::OperatorCardComponent < ApplicationComponent
  def post_initialize(form:)
    @form = form
  end

  def used_operator
    @form.object
  end

  delegate :operator, to: :used_operator
  delegate :elite, :skill, to: :used_operator, prefix: true

  def operator_image_url
    used_operator.operator.avatar
  end

  def operator_skill_image_url(skill)
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_skchr_#{operator.game_id.split('_').last}_#{skill + 1}.png"
  end

  def operator_name
    used_operator.operator.name
  end

  def tooltip_id
    "operator_#{used_operator.operator_id}"
  end

  def max_elite
    3
  end

  def max_skill
    3
  end

  # Hacky way to get for attribute of label, consider using simple form custom components
  def label_for(field, value)
    "clear_used_operators_attributes_#{@form.index}_#{field}_#{value}"
  end
end
