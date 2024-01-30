# frozen_string_literal: true

require 'open-uri'

module FetchGameData
  class FetchLatestOperatorsData < ApplicationService
    SOURCES = {
      en: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/character_table.json',
      jp: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/ja_JP/gamedata/excel/character_table.json',
      'zh-CN': 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/character_table.json'
    }
    SKILL_DATA_URL = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/skill_table.json'

    def self.i18n?
      true
    end

    def initialize(source = nil, destroy_invalid: false)
      @source = source || SOURCES[I18n.locale]
      @destroy_invalid = destroy_invalid
    end

    def call
      operator_table = yield FetchJson.call(source)
      skill_data = yield FetchJson.call(SKILL_DATA_URL)
      fetch_logger = FetchLogger.new(Operator.name)

      operator_table.each do |game_id, operator|
        valid = valid_operator?(operator, game_id)
        unless valid
          delete_invalid_operators(game_id) if destroy_invalid
          next
        end

        name = operator['name']
        rarity = operator['rarity'].split('_').last.to_i - 1
        skill_game_ids = skill_game_ids(operator)
        operator = Operator.find_or_initialize_by(game_id:)
        operator.update!(name:, rarity:, skill_game_ids:, skill_icon_ids: skill_icon_ids(skill_game_ids, skill_data))
        fetch_logger.log_write(operator, game_id)
      rescue ActiveRecord::RecordInvalid
        log_info("Failed to write operator #{name}")
      end

      fetch_logger.log_summary
    end

    private

    attr_reader :source, :destroy_invalid

    def skill_icon_ids(skill_game_ids, skill_data)
      skill_game_ids.map { |skill_id| skill_data[skill_id]['iconId'] || skill_id }
    end

    def delete_invalid_operators(game_id)
      operator = Operator.find_by(game_id:)

      return if operator.blank?

      UsedOperator.where(operator_id: operator).destroy_all
      operator.destroy
    end

    def skill_game_ids(operator)
      operator['skills'].map { |skill| skill['skillId'] }
    end

    def current_game_ids
      @current_game_ids ||= Operator.pluck(:game_id)
    end

    def cn_locale?
      I18n.locale == :'zh-CN'
    end

    def valid_operator?(operator, game_id)
      return false if cn_locale? && current_game_ids.exclude?(game_id)

      !operator['subProfessionId']&.start_with?('notchar') && # Everyone's summon
        operator['profession'] != 'TOKEN' && # Phantom's summon
        !operator['isNotObtainable'] # IS extra ops
    end
  end
end
