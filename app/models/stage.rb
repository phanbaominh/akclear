class Stage < ApplicationRecord
  STAGEABLE_TYPES = [Event, Annihilation, Episode].map(&:to_s).freeze
  CHALLENGE_MODE_ID = '#f#'.freeze
  belongs_to :stageable, polymorphic: true
  scope :non_challenge_mode, -> { where.not('game_id LIKE ?', "%#{CHALLENGE_MODE_ID}") }
  scope :challenge_mode, -> { where('game_id LIKE ?', "%#{CHALLENGE_MODE_ID}") }
  scope :with_environment, ->(environment) { where('game_id LIKE ?', "#{environment.to_game_id}%") }

  delegate :annihilation?, :has_environments?, to: :stageable

  def event?
    stageable.is_a?(Event)
  end

  def challenge_mode?
    game_id&.include?(CHALLENGE_MODE_ID)
  end

  def environment
    return unless stageable.has_environments?

    game_id_prefix = game_id.split('_').first
    Episode::Environment::ENVIRONMENT_TO_GAME_ID.invert[game_id_prefix]
  end
end
