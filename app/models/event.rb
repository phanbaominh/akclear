class Event < ApplicationRecord
  has_many :stages, dependent: :nullify
end
