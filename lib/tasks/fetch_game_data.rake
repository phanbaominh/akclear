namespace :fetch_game_data do
  # TODO: Use https://github.com/shioyama/mobility to fetch and store data from other languages (jp, ch, kr)
  task fetch_latest_operator_table: :environment do
    FetchGameData::FetchLatestOperatorsData.call
  end

  task fetch_latest_events_data: :environment do
    FetchGameData::FetchLatestEventsData.call
  end

  task fetch_latest_episodes_data: :environment do
    FetchGameData::FetchLatestEpisodesData.call
  end

  task fetch_latest_stages_data: :environment do
    FetchGameData::FetchLatestStagesData.call
  end

  task fetch_annihilations_data: :environment do
    FetchGameData::FetchAnnihilationsData.call
  end
end
