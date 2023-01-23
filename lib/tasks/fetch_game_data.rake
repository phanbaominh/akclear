namespace :fetch_game_data do
  task fetch_latest_operator_table: :environment do
    FetchLatestOperatorsData.call
  end

  task fetch_latest_events_data: :environment do
    FetchLatestEventsData.call
  end
end
