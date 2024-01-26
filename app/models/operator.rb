class Operator < ApplicationRecord
  # https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/char_002_amiya.png
  include Translatable
  include Rarifiable
  has_one_attached :sprite

  scope :from_clear_ids, lambda { |clear_ids|
                           where(id: UsedOperator.where(used_operators: { clear_id: clear_ids }).select(:operator_id))
                         }

  def avatar
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/#{game_id}.png"
  end

  def inspect
    "OP-#{name} #{skill_game_ids}"
  end

  # put here instead of Translatable because of to override reader of Mobility
  def name(**kwargs)
    cached_name || super(**kwargs)
  end
end
