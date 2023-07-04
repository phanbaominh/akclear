require 'rails_helper'

RSpec.describe Stage, type: :model do
  it { is_expected.to belong_to(:stageable) }

  describe 'scopes' do
    describe '.with_environment' do
      let_it_be(:story_stage) { create(:stage, game_id: 'easy_10-01') }
      let_it_be(:standard_stage) { create(:stage, game_id: 'main_10-01') }
      let_it_be(:adverse_stage) { create(:stage, game_id: 'tough_10-01') }

      it 'returns stage with easy in game id for story environment' do
        expect(described_class.with_environment(Episode::Environment.new(Episode::Environment::STORY))).to eq([story_stage])
      end

      it 'returns stage with main in game id for standard environment' do
        expect(described_class.with_environment(Episode::Environment.new(Episode::Environment::STANDARD))).to eq([standard_stage])
      end

      it 'returns stage with tough in game id for adverse environment' do
        expect(described_class.with_environment(Episode::Environment.new(Episode::Environment::ADVERSE))).to eq([adverse_stage])
      end
    end
  end
end
