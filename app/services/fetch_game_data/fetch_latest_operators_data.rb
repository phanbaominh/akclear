# frozen_string_literal: true

require 'open-uri'

module FetchGameData
  class FetchLatestOperatorsData < ApplicationService
    OPERATOR_TABLE_SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json'
    def initialize(source = OPERATOR_TABLE_SOURCE)
      @source = source
    end

    def call
      operator_table = yield FetchJson.call(source)
      fetch_logger = FetchLogger.new(Operator.name)

      operator_table.each do |game_id, operator|
        next unless valid_operator?(operator)

        name = operator['name']
        rarity = operator['rarity']
        operator = Operator.find_or_initialize_by(game_id:)
        operator.update!(name:, rarity:)
        fetch_logger.log_write(operator, game_id)
      rescue ActiveRecord::RecordInvalid
        log_info("Failed to write operator #{name}")
      end

      fetch_logger.log_summary
    end

    private

    attr_reader :source

    def valid_operator?(operator)
      !operator['subProfessionId'].start_with?('notchar')
    end
  end
end
