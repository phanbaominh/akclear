require 'rails_helper'

describe Clear::HardTagList do
  describe '#add_tags' do
    context 'when valid tags' do
      it 'adds tags' do
        hard_tag_list = described_class.new(['High-end'])

        result = hard_tag_list.add_tags(%w[Low-end Low-end])

        expect(result).to be_success
        expect(result.value!).to match_array(%w[Low-end High-end])
      end
    end

    context 'when invalid tags' do
      it 'does not add tags' do
        hard_tag_list = described_class.new(['High-end'])

        result = hard_tag_list.add_tags(%w[Low-end Medium-end])

        expect(result).to be_failure
        expect(result.failure).to include('Medium-end')
      end
    end
  end

  describe '#remove_tags' do
    it 'removes tags' do
      hard_tag_list = described_class.new(%w[Low-end High-end])

      result = hard_tag_list.remove_tags(%w[Low-end No-6-stars])

      expect(result).to be_success
      expect(result.value!).to eq(%w[High-end])
    end
  end
end
