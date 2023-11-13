module User::Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, dependent: :destroy
    has_many :liked_clears, class_name: 'Clear', through: :likes, source: :clear
  end

  def like(clear)
    liked_clears << clear
  end

  def unlike(clear)
    liked_clears.delete(clear)
  end

  def liked?(clear)
    liked_clears.to_a.include?(clear)
  end
end
