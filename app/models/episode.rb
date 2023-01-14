class Episode < ApplicationRecord
  has_many :stages, as: :stageable, dependent: :nullify
end
