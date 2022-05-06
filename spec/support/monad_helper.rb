# frozen_string_literal: true

RSpec.shared_examples 'handling exception' do
  let(:exception) { StandardError.new('unexpected error') }

  it 'fails', :aggregate_failures do
    expect(result).not_to be_success
    expect(result.failure).to eq(exception)
  end
end
