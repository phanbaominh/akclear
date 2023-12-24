class Annihilation < ApplicationRecord
  include Stageable
  scope :latest, -> { where(end_time: Time.current..).order(end_time: :asc).limit(1) }

  def challengable?
    false
  end
end
