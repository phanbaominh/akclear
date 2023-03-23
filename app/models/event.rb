# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :stages, dependent: :nullify, as: :stageable

  def self.latest
    find_by(latest: true)
  end
end
