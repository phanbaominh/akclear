# frozen_string_literal: true

module FetchGameData
  class FetchAnnihilationsData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/stage_table.json'

    def call
      stages_data = yield FetchJson.call(SOURCE)
      stages_data = stages_data['stages']

      count = 0
      stages_data.each do |stage_id, stage_data|
        next unless valid_stage?(stage_data)

        stageable = Annihilation.create_with(name: stage_data['name']).find_or_create_by!(game_id: stage_id)
        next if stageable.blank?

        code = stage_data['name']
        zone = stage_data['zoneId'][-1]
        stage = stageable.stages.create_with(code:, zone:).find_or_create_by!(game_id: stage_id)

        next unless stage.previously_new_record?

        count += 1
        log_info("Stage #{code} was succesfully created!")
      end

      log_info("#{count} stages were succesfully created!")
      Success()
    end

    private

    def valid_stage?(stage_data)
      stage_data['stageType'] == 'CAMPAIGN'
    end
  end
end
