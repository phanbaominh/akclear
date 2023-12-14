# frozen_string_literal: true

class UsedOperatorPresenter < ApplicationPresenter
  delegate :operator, to: :object
  delegate :name, :avatar, to: :operator

  def self.elite_image_url(elite)
    "images/elite#{elite}.png"
  end

  def self.skill_image_url(skill_id)
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_#{skill_id}.png"
  end

  def skill_image_url
    self.class.skill_image_url(operator.skill_game_ids[object.skill.to_i - 1])
  end

  def elite_image_url
    self.class.elite_image_url(object.elite || 0)
  end

  def verification_icon
    return if need_to_be_verified?

    case object.verification_status
    when Verification::REJECTED
      'x-mark'
    when Verification::ACCEPTED
      'check'
    end
  end

  def verification_text
    return if need_to_be_verified?

    case object.verification_status
    when Verification::REJECTED
      I18n.t(:rejected)
    when Verification::ACCEPTED
      I18n.t(:verified)
    end
  end

  def verification_color(prefix, suffix: nil, require_prefix: false)
    # for tailwind purge: badge-success badge-error text-success-content text-error-content outline-success text-success
    return if need_to_be_verified?

    color = if object.verification_accepted?
              "#{prefix}-success"
            else
              "#{prefix}-error"
            end + (suffix ? "-#{suffix}" : '')
    require_prefix ? "#{prefix} #{color}" : color
  end

  def skill_level_code
    return unless (skill_level = object.skill_level)

    if skill_level < 8
      "L#{skill_level}"
    else
      "M#{skill_level - 7}"
    end
  end

  def skill_level_option
    return unless (skill_level = object.skill_level)

    if skill_level < 8
      I18n.t('used_operator_form.skill_level', skill_level:)
    else
      I18n.t('used_operator_form.skill_mastery', skill_mastery: skill_level - 7)
    end
  end

  private

  def need_to_be_verified?
    object.changed? || !object.verified?
  end
end
