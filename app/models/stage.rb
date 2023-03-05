class Stage < ApplicationRecord
  belongs_to :stageable, polymorphic: true

  def event?
    stageable.is_a?(Event)
  end
end
