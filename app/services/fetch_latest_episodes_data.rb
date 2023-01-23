# frozen_string_literal: true

class FetchLatestEpisodesData < ApplicationService
  SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/zone_table.json'

  def call
    episodes_data = yield FetchJson.call(SOURCE)
    episodes_data = episodes_data['zones']
    count = 0
    episodes_data.each do |episode_id, episode_data|
      next unless valid_episode?(episode_data)

      name = episode_data['zoneNameSecond']
      number = episode_id.split('_').last
      episode = Episode.create_with(name:, number:).find_or_create_by!(game_id: episode_id)

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
