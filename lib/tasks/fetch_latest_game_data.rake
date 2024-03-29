namespace :fetch_latest_game_data do
  # TODO: Use https://github.com/shioyama/mobility to fetch and store data from other languages (jp, ch, kr)
  task operators: :environment do
    FetchGameData::FetchLatestOperatorsData.call
  end

  task events: :environment do
    FetchGameData::FetchLatestEventsData.call
  end

  task episodes: :environment do
    FetchGameData::FetchLatestEpisodesData.call
  end

  task stages: :environment do
    FetchGameData::FetchLatestStagesData.call
  end

  task annihilations: :environment do
    FetchGameData::FetchAnnihilationsData.call
  end

  task all: :environment do
    ImportGameDataJob.new.perform
  end

  task images: :environment do
    [
      FetchGameData::FetchEpisodesBanners,
      FetchGameData::FetchEventBanners,
      FetchGameData::FetchOperatorsSkillsIcons
    ].map do |service|
      service.call
    rescue StandardError => e
      Rails.logger.error("Failed to #{service.to_s.demodulize.titleize.downcase}: #{e.message}")
    end
  end
end
