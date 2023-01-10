require 'support/rake'

describe 'fetch_game_data:fetch_latest_operator_table' do
  include_context 'rake'

  it 'calls the correct service' do
    allow(FetchLatestOperatorsData).to receive(:call)

    subject.invoke

    expect(FetchLatestOperatorsData).to have_received(:call)
  end
end
