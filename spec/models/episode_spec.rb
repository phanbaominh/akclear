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
end
