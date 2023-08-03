class Operator < ApplicationRecord
  extend Mobility
  translates :name, type: :string
  # https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/char_002_amiya.png
  include Operator::Rarifiable
  has_one_attached :sprite

  def avatar
    "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/avatars/#{game_id}.png"
  end
end
