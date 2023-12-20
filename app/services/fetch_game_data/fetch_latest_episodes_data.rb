# frozen_string_literal: true

module FetchGameData
  class FetchLatestEpisodesData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/zone_table.json'

    def initialize(json: false)
      @json = json
    end

    def call
      episodes_data = yield FetchJson.call(SOURCE)
      episodes_data = episodes_data['zones']
      episodes = episodes_data.filter_map do |episode_id, episode_data|
        next unless valid_episode?(episode_data)

        store_episode(episode_id, episode_data)
      end

      unless json?
        newly_created_episodes_count = episodes.count(&:previously_new_record?)
        log_info("Fetching completed! #{newly_created_episodes_count} new episodes were created!")
      end

      Success(episodes)
    end

    private

    def json?
      @json
    end

    def store_episode(episode_id, episode_data)
      name = episode_data['zoneNameSecond']
      number = episode_id.split('_').last

      if json?
        {
          name:,
          number:,
          game_id: episode_id
        }
      else

        episode = Episode.find_or_initialize_by(game_id: episode_id)
        episode.update!(name:, number:)

        log_info("Episode #{name} was created successfully!") if episode.previously_new_record?
        episode
      end
    end

    def valid_episode?(episode_data)
      return false unless episode_data['type'] == 'MAINLINE'

      true
    end
  end
end
