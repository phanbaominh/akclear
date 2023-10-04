require 'rails_helper'

describe Episode::Environment do
  let(:environment) { described_class.new('adverse') }

  describe '.available_environments' do
    let_it_be(:episode, reload: true) { create(:episode) }

    context 'when episode is episode 9' do
      it 'returns story and standard' do
        episode.number = 9
        expect(described_class.available_environments(episode)).to eq(%w[story standard])
      end
    end

    context 'when episode is not episode 9' do
      it 'returns all environments' do
        expect(described_class.available_environments(episode)).to eq(%w[story standard adverse])
      end
    end
  end

  describe '#to_s' do
    it { expect(environment.to_s).to eq('adverse') }
  end

  describe '==' do
    it 'can compare with string' do
      string_value = 'adverse'
      expect(string_value).to eq(environment)
    end
  end

  describe '#to_game_id' do
    environment_to_game_id =
      {
        'story' => 'easy',
        'standard' => 'main',
        'adverse' => 'tough'
      }

    environment_to_game_id.each do |env, game_id|
      it "returns game id #{game_id} based on environment #{env}" do
        expect(described_class.new(env).to_game_id).to eq(game_id)
      end
    end
  end
end
