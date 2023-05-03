# frozen_string_literal: true

class UsedOperatorPresenter < ApplicationPresenter
  delegate :operator, to: :object
  delegate :name, :avatar, to: :operator

  def self.elite_image_url(elite)
    "images/elite#{elite}.png"
  end

  def self.skill_image_url(game_id, skill)
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_skchr_#{game_id.split('_').last}_#{(skill || 0) + 1}.png"
  end

  def skill_image_url
    self.class.skill_image_url(operator.game_id, object.skill)
  end

  def elite_image_url
    self.class.elite_image_url(object.elite)
  end
end
