require 'support/rake'

describe 'fetch_game_data:fetch_latest_operator_table' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchLatestOperatorsData).to receive(:call)

    subject.invoke

    expect(FetchLatestOperatorsData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_events_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchLatestEventsData).to receive(:call)

    subject.invoke

    expect(FetchLatestEventsData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_episodes_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchLatestEpisodesData).to receive(:call)

    subject.invoke

    expect(FetchLatestEpisodesData).to have_received(:call)
  end
end

describe 'fetch_game_data:fetch_latest_stages_data' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchLatestStagesData).to receive(:call)

    subject.invoke

    expect(FetchLatestStagesData).to have_received(:call)
  end
end
