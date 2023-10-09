# frozen_string_literal: true

require 'open-uri'

module FetchGameData
  class FetchLatestOperatorsData < ApplicationService
    SOURCES = {
      en: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json',
      jp: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/ja_JP/gamedata/excel/character_table.json'
    }

    def self.i18n?
      true
    end

    def initialize(source = nil)
      @source = source || SOURCES[I18n.locale]
    end

    def call
      operator_table = yield FetchJson.call(source)
      fetch_logger = FetchLogger.new(Operator.name)

      operator_table.each do |game_id, operator|
        next unless valid_operator?(operator)

        name = operator['name']
        rarity = operator['rarity']
        skill_game_ids = skill_game_ids(operator)
        operator = Operator.find_or_initialize_by(game_id:)
        operator.update!(name:, rarity:, skill_game_ids:)
        fetch_logger.log_write(operator, game_id)
      rescue ActiveRecord::RecordInvalid
        log_info("Failed to write operator #{name}")
      end

      fetch_logger.log_summary
    end

    private

    attr_reader :source

    def skill_game_ids(operator)
      operator['skills'].map { |skill| skill['skillId'] }
    end

    def valid_operator?(operator)
      !operator['subProfessionId'].start_with?('notchar')
    end
  end
end
