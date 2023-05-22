module User::Likeable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :liked_clears, class_name: 'Clear', join_table: :likes # rubocop:disable Rails/HasAndBelongsToMany
  end

  def like(clear)
    liked_clears << clear
  end

  def unlike(clear)
    liked_clears.delete(clear)
  end
end
