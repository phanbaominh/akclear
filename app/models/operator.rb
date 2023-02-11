class Operator < ApplicationRecord
  # https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/char_002_amiya.png
  has_one_attached :sprite

  def avatar
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/#{game_id}.png"
  end
end
