# frozen_string_literal: true

class Episode::Environment
  ENVIRONMENTS = [
    STORY = 'story',
    STANDARD = 'standard',
    ADVERSE = 'adverse'
  ].freeze

  ENVIRONMENT_TO_GAME_ID = {
    STORY => 'easy',
    STANDARD => 'main',
    ADVERSE => 'tough'
  }.freeze

  def self.available_environments(episode)
    if episode.episode_9?
      ENVIRONMENTS.reject { |env| env == ADVERSE }
    else
      ENVIRONMENTS
    end
  end

  attr_reader :environment

  def initialize(environment)
    @environment = environment
  end

  def to_game_id
    ENVIRONMENT_TO_GAME_ID[environment]
  end

  def to_s
    environment
  end

  def to_str
    environment
  end

  def ==(other)
    to_str == other.to_str
  end
end
