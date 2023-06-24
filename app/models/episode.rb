class Episode < ApplicationRecord
  include Stageable

  scope :latest, -> { where(id: order(:number).last) }
end
