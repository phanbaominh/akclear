class Annihilation < ApplicationRecord
  include GlobalID::Identification
  has_many :stages, as: :stageable, dependent: :nullify
end
