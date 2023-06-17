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
    [
      FetchGameData::FetchLatestOperatorsData,
      FetchGameData::FetchLatestEventsData,
      FetchGameData::FetchLatestEpisodesData,
      FetchGameData::FetchAnnihilationsData,
      FetchGameData::FetchLatestStagesData,
      FetchGameData::FetchEpisodesBanners,
      FetchGameData::FetchEventBanners
    ].map(&:call)
  end
end
