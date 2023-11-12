# frozen_string_literal: true

module FetchGameData
  class FetchOperatorsSkillsIcons < ApplicationService
    include ImageStorable
    SKILL_DATA_URL = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/skill_table.json'

    def self.images_path
      Rails.root.join('app/javascript/images/skills')
    end

    def initialize(overwrite: false)
      @overwrite = overwrite
    end

    def call
      log_info('Fetching skill data...')
      skill_data = yield FetchJson.call(SKILL_DATA_URL)
      store_images(build_skill_id_to_image_url(skill_data))
    end

    private

    attr_reader :overwrite

    def skill_id_to_image_url(skill_icon_id)
      "https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_#{CGI.escape(skill_icon_id)}.png"
    end

    def build_skill_id_to_image_url(skill_data)
      Operator.all.map.with_object({}) do |operator, file_name_to_image_url|
        operator.skill_game_ids.each do |skill_id|
          file_name_to_image_url[skill_id] = skill_id_to_image_url(skill_data[skill_id]['iconId'] || skill_id)
        end
      end
    end

    def image_storable
      :skill
    end
  end
end
