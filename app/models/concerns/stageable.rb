# frozen_string_literal: true

module Stageable
  extend ActiveSupport::Concern
  include GlobalID::Identification

  included do
    has_many :stages, dependent: :nullify, as: :stageable
    scope :latest, -> { where(end_time: Time.current..).order(end_time: :desc) }
    scope :selectable, -> { all }
  end
end
