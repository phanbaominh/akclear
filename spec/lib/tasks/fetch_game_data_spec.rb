require 'support/rake'

describe 'fetch_game_data:fetch_latest_operator_table' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestOperatorsData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestOperatorsData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_events_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestEventsData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestEventsData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_episodes_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestEpisodesData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestEpisodesData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_stages_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestStagesData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestStagesData).to have_received(:call)
  end
end
