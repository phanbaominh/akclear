class Annihilation < ApplicationRecord
  include Stageable

  def challengable?
    false
  end
end
