# frozen_string_literal: true

class ImportGameDataJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :system
  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { 'import_game_data_job' }
  )

  def perform
    [
      FetchGameData::FetchLatestOperatorsData,
      FetchGameData::FetchLatestEventsData,
      FetchGameData::FetchLatestEpisodesData,
      FetchGameData::FetchAnnihilationsData,
      FetchGameData::FetchLatestStagesData
    ].map do |service|
      if service.try(:i18n?)
        I18n.available_locales.each do |locale|
          I18n.with_locale(locale) do
            service.call
          end
        end
      else
        service.call
      end
    rescue StandardError => e
      Rails.logger.error("Failed to #{service.to_s.demodulize.titleize.downcase}: #{e.message}")
    end
  end
end
