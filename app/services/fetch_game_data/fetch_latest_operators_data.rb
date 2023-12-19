# frozen_string_literal: true

require 'open-uri'

module FetchGameData
  class FetchLatestOperatorsData < ApplicationService
    SOURCES = {
      en: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/character_table.json',
      jp: 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/ja_JP/gamedata/excel/character_table.json'
    }

    def self.i18n?
      true
    end

    def initialize(source = nil, destroy_invalid: false)
      @source = source || SOURCES[I18n.locale]
      @destroy_invalid = destroy_invalid
    end

    def call
      operator_table = yield FetchJson.call(source)
      fetch_logger = FetchLogger.new(Operator.name)

      operator_table.each do |game_id, operator|
        valid = valid_operator?(operator)
        unless valid
          delete_invalid_operators(game_id) if destroy_invalid
          next
        end

        name = operator['name']
        rarity = operator['rarity'].split('_').last.to_i - 1
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

    attr_reader :source, :destroy_invalid

    def delete_invalid_operators(game_id)
      operator = Operator.find_by(game_id:)

      return if operator.blank?

      UsedOperator.where(operator_id: operator).destroy_all
      operator.destroy
    end

    def skill_game_ids(operator)
      operator['skills'].map { |skill| skill['skillId'] }
    end

    def valid_operator?(operator)
      !operator['subProfessionId']&.start_with?('notchar') && # Everyone's summon
        operator['profession'] != 'TOKEN' && # Phantom's summon
        !operator['isNotObtainable'] # IS extra ops
    end
  end
end
