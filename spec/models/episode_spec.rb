require 'rails_helper'

RSpec.describe Episode, type: :model do
  it { is_expected.to have_many(:stages).dependent(:nullify) }

  describe '.latest' do
    let_it_be(:episode_1) { create(:episode, number: 3) }
    let_it_be(:episode_2) { create(:episode, number: 1) }

    it 'returns episode with latest number' do
      expect(described_class.latest.first).to eq(episode_1)
    end
  end

  describe '#challengable?' do
    context 'when episode has environments' do
      context 'when episode is episode 9' do
        it 'returns true' do
          expect(described_class.new(number: 9)).to be_challengable
        end
      end

      context 'when episode is greater 9' do
        it 'returns false' do
          expect(described_class.new(number: 10)).not_to be_challengable
        end
      end
    end

    context 'when episode does not have environments' do
      it 'returns true' do
        expect(described_class.new(number: 1)).to be_challengable
      end
    end
  end
end
