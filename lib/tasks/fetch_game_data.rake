namespace :fetch_game_data do
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
end
