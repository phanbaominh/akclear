require 'support/rake'

describe 'fetch_latest_game_data:operators' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestOperatorsData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestOperatorsData).to have_received(:call)
  end
end

describe 'fetch_latest_game_data:events' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestEventsData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestEventsData).to have_received(:call)
  end
end

describe 'fetch_latest_game_data:episodes' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestEpisodesData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestEpisodesData).to have_received(:call)
  end
end

describe 'fetch_latest_game_data:stages' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchGameData::FetchLatestStagesData).to receive(:call)

    subject.invoke

    expect(FetchGameData::FetchLatestStagesData).to have_received(:call)
  end
end
