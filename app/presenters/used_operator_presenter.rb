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

  def verification_outline_class
    case object.verification_status
    when Verification::ACCEPTED
      'outline outline-primary'
    when Verification::DECLINED
      'outline outline-error'
    end
  end
end
