module Clear::Likeable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :likers, class_name: 'User', join_table: :likes # rubocop:disable Rails/HasAndBelongsToMany
  end

  def likes_count
    likers.count
  end

  def liked?
    Current.user.liked?(self)
  end
end
