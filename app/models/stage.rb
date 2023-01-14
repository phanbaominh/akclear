class Stage < ApplicationRecord
  belongs_to :stageable, polymorphic: true
end
