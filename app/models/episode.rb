class Episode < ApplicationRecord
  include Stageable

  scope :latest, -> { where(id: order(:number).last) }

  def self.challengable?
    true
  end
end
