# frozen_string_literal: true

class Episode < ApplicationRecord
  include Stageable

  scope :latest, -> { where(id: order(:number).last) }

  def challengable?
    !has_environments? || episode_9?
  end

  def has_environments? # rubocop:disable Naming/PredicateName
    number >= 9
  end

  def episode_9?
    number == 9
  end
end
