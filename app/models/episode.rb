class Episode < ApplicationRecord
  include Stageable

  scope :latest, -> { order(:number).last }
end
