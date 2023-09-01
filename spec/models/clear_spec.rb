require 'rails_helper'

RSpec.describe Clear, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:submitter) }
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:channel).optional }
    it { is_expected.to have_many(:used_operators) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:link) }
  end

  describe '#normalize_link' do
    context 'when the link has changed' do
      it 'normalizes the link when saving' do
        clear = build(:clear, link: 'https://youtu.be/aAfeBGKoZeI?t=34')

        clear.save

        expect(clear.link).to eq('https://youtube.com/watch?v=aAfeBGKoZeI')
      end
    end
  end

  describe '#assign_channel' do
    context 'when the link has changed' do
      let(:link) { 'https://youtube.com/watch?v=123' }

      before { allow(Channel).to receive(:from).with(link).and_return(channel) }

      context 'when new channel' do
        let_it_be(:channel) { build(:channel) }

        it 'assigns the channel' do
          clear = build(:clear, link:)

          clear.save

          expect(channel).to be_persisted
          expect(clear.channel).to eq(channel)
        end
      end

      context 'when existing channel' do
        let_it_be(:channel) { create(:channel) }

        it 'assigns the channel' do
          clear = build(:clear, link:)

          clear.save

          expect(clear.channel).to eq(channel)
        end
      end
    end

    context 'when the link has not changed' do
      it 'does not assign the channel' do
        allow(Channel).to receive(:from)
        clear = build(:clear, link: nil)

        clear.save

        expect(Channel).not_to have_received(:from)
      end
    end
  end
end
