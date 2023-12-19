module Clear::Likeable
  extend ActiveSupport::Concern

  included do
    # delete_all because likes does not have id
    has_many :likes, dependent: :delete_all
    has_many :likers, class_name: 'User', through: :likes, source: :user
  end

  def likes_count
    likes.size
  end

  def liked?
    Current.user&.liked?(self)
  end
end
