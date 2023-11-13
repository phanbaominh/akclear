module Clear::Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, dependent: :destroy
    has_many :likers, class_name: 'User', through: :likes, source: :user
  end

  def likes_count
    likers.size
  end

  def liked?
    Current.user&.liked?(self)
  end
end
