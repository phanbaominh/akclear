class Stage < ApplicationRecord
  STAGEABLE_TYPES = Types::String.enum('Event', 'Episode')
  CHALLENGE_MODE_ID = '#f#'.freeze
  belongs_to :stageable, polymorphic: true
  scope :non_challenge_mode, -> { where.not('game_id LIKE ?', "%#{CHALLENGE_MODE_ID}") }
  scope :challenge_mode, -> { where('game_id LIKE ?', "%#{CHALLENGE_MODE_ID}") }

  def event?
    stageable.is_a?(Event)
  end

  def challenge_mode?
    game_id&.include?(CHALLENGE_MODE_ID)
  end
end
