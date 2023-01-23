# frozen_string_literal: true

require 'open-uri'

class FetchLatestOperatorsData < ApplicationService
  OPERATOR_TABLE_SOURCE = 'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json'
  def initialize(source = OPERATOR_TABLE_SOURCE)
    @source = source
  end

  def call
    operator_table = yield FetchJson.call(source)
    count = 0

    operator_table.each do |game_id, operator|
      name = operator['name']
      log_info("Creating operator #{name}... ")
      Operator.where(name:, game_id:).first_or_create!
      log_info("Operator #{name} created sucessfully!")
      count += 1
    rescue ActiveRecord::RecordInvalid
      log_info("Failed to create operator #{name}")
    end

    log_info("Finished fetching operator data! #{count} new operators created!")
  end

  private

  attr_reader :source
end
