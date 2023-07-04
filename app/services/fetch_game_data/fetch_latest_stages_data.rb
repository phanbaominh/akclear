# frozen_string_literal: true

module FetchGameData
  class FetchLatestStagesData < ApplicationService
    SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/stage_table.json'

    def call
      stages_data = yield FetchJson.call(SOURCE)
      stages_data = stages_data['stages']

      count = 0
      stages_data.each do |stage_id, stage_data|
        next unless valid_stage?(stage_data)

        stageable = stageable(stage_data)
        next if stageable.blank?

        code = stage_data['code']
        zone = zone(stageable, stage_data['zoneId'])
        stage = stageable.stages.find_or_initialize_by(game_id: stage_id)
        stage.update!(code:, zone:)

        next unless stage.previously_new_record?

        count += 1
        log_info("Stage #{code} was succesfully created!")
      end

      log_info("#{count} stages were succesfully created!")
      Success()
    end

    private

    def valid_stage?(stage_data)
      return false if story_stage?(stage_data)
      return false if tutorial_stage?(stage_data)
      return false if ap_cost_0?(stage_Data)

      true
    end

    def story_stage?(stage_data)
      stage_data['isStoryOnly']
    end

    def tutorial_stage?(stage_data)
      stage_data['code'].match?(/TR-/) && stage_data['stageId'].match?(/tr/)
    end

    def ap_cost_0?(stage_data)
      stage_data['apCost'].to_s == '0'
    end

    def stageable(stage_data)
      stageable_id = nil
      stageable_klass =
        case stage_data['stageType']
        when 'MAIN', 'SUB'
          stageable_id = stage_data['zoneId']
          Episode
        when 'ACTIVITY'
          stageable_id = stage_data['stageId'].split('_').first
          Event
        end
      stageable_klass&.find_by(game_id: stageable_id) if stageable_id
    end

    def zone(stageable, zone_id)
      if stageable.is_a?(Episode)
        1
      else
        zone_id[-1]
      end
    end
  end
end
