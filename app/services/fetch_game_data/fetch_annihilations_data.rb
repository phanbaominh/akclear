# frozen_string_literal: true

module FetchGameData
  class FetchAnnihilationsData < ApplicationService
    STAGES_SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/stage_table.json'
    ANNIHILATIONS_SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/campaign_table.json'

    def call
      stages_data = yield FetchJson.call(STAGES_SOURCE)
      annihilations_data = yield FetchJson.call(ANNIHILATIONS_SOURCE)
      stages_data = stages_data['stages']
      end_times_data = annihilations_data['campaignRotateStageOpenTimes']

      annihilation_fetch_logger = FetchLogger.new(Annihilation.name)
      stage_fetch_logger = FetchLogger.new(Stage.name)

      stages_data.each do |stage_id, stage_data|
        next unless valid_stage?(stage_data)

        annihilation = Annihilation.find_or_create_by!(game_id: stage_id)
        end_time = end_times_data.find { |et| et['stageId'] == stage_id }.try(:[], 'endTs')
        end_time = Time.zone.at(end_time) if end_time
        annihilation.update!(name: stage_data['name'], end_time:)

        annihilation_fetch_logger.log_write(annihilation, stage_id)

        next if annihilation.blank?

        code = stage_data['name']
        zone = stage_data['zoneId'][-1]
        stage = annihilation.stages.find_or_initialize_by(game_id: stage_id)
        stage.update!(code:, zone:)

        stage_fetch_logger.log_write(stage, stage_id)
      end

      annihilation_fetch_logger.log_summary
      stage_fetch_logger.log_summary
      Success()
    end

    private

    def valid_stage?(stage_data)
      stage_data['stageType'] == 'CAMPAIGN'
    end
  end
end
