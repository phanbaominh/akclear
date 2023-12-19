# frozen_string_literal: true

module FetchGameData
  class FetchLatestEpisodesData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/zone_table.json'

    def call
      episodes_data = yield FetchJson.call(SOURCE)
      episodes_data = episodes_data['zones']
      count = 0
      episodes_data.each do |episode_id, episode_data|
        next unless valid_episode?(episode_data)

        name = episode_data['zoneNameSecond']
        number = episode_id.split('_').last
        episode = Episode.find_or_initialize_by(game_id: episode_id)
        episode.update!(name:, number:)

        next unless episode.previously_new_record?

        log_info("Episode #{name} was created successfully!")
        count += 1
      end

      log_info("Fetching completed! #{count} new episodes were created!")

      Success()
    end

    private

    def valid_episode?(episode_data)
      return false unless episode_data['type'] == 'MAINLINE'

      true
    end
  end
end
