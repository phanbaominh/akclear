# frozen_string_literal: true

class Event < ApplicationRecord
  include GlobalID::Identification
  has_many :stages, dependent: :nullify, as: :stageable

  scope :latest, -> { where(end_time: Time.current..).order(end_time: :desc) }
end
