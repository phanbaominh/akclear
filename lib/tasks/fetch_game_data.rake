namespace :fetch_game_data do
  task fetch_latest_operator_table: :environment do
    FetchLatestOperatorsData.call
  end

  task fetch_latest_events_data: :environment do
    FetchLatestEventsData.call
  end

  task fetch_latest_episodes_data: :environment do
    FetchLatestEpisodesData.call
  end

  task fetch_latest_stages_data: :environment do
    FetchLatestStagesData.call
  end
end
