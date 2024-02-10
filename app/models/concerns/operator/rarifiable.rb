# frozen_string_literal: true

module Operator::Rarifiable
  extend ActiveSupport::Concern

  RARITIES = [
    ONE_STAR = 'one_star',
    TWO_STARS = 'two_stars',
    THREE_STARS = 'three_stars',
    FOUR_STARS = 'four_stars',
    FIVE_STARS = 'five_stars',
    SIX_STARS = 'six_stars'
  ].freeze

  # convert the below array to a hash with keys as the rarity and values as the max elite
  RARITIES_TO_MAX_ELITE = {
    ONE_STAR => 0,
    TWO_STARS => 0,
    THREE_STARS => 1,
    FOUR_STARS => 2,
    FIVE_STARS => 2,
    SIX_STARS => 2
  }.freeze
  RARITIES_TO_NUMBER_OF_SKILLS = {
    ONE_STAR => 0,
    TWO_STARS => 0,
    THREE_STARS => 1,
    FOUR_STARS => 2,
    FIVE_STARS => 2,
    SIX_STARS => 3
  }.freeze
  RARITIES_TO_MAX_LEVEL = {
    ONE_STAR => [30],
    TWO_STARS => [30],
    THREE_STARS => [40, 55],
    FOUR_STARS => [45, 60, 70],
    FIVE_STARS => [50, 70, 80],
    SIX_STARS => [50, 80, 90]
  }.freeze
  RARITIES_TO_MAX_SKILL_LEVEL = {
    ONE_STAR => [0],
    TWO_STARS => [0],
    THREE_STARS => [4, 7],
    FOUR_STARS => [4, 7, 7],
    FIVE_STARS => [4, 7, 7],
    SIX_STARS => [4, 7, 7]
  }.freeze

  included do
    enum :rarity, RARITIES
  end

  def max_elite
    RARITIES_TO_MAX_ELITE[rarity]
  end

  def max_skill(elite:)
    if elite == 2
      skill_game_ids&.length
    else
      [2, RARITIES_TO_NUMBER_OF_SKILLS[rarity], skill_game_ids&.length].compact.min
    end
  end

  def max_level(elite:)
    RARITIES_TO_MAX_LEVEL[rarity][elite]
  end

  def max_skill_level(elite:)
    RARITIES_TO_MAX_SKILL_LEVEL[rarity][elite]
  end

  def possible_elite_with_level(level)
    possible_elites = Array.new(max_elite + 1, 0)
    RARITIES_TO_MAX_LEVEL[rarity].each_with_index do |max_level, elite|
      possible_elites.delete(elite) if level > max_level
    end
    possible_elites
  end

  def has_skills?
    skill_game_ids&.length&.positive?
  end
end
