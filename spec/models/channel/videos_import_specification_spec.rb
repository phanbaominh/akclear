require 'rails_helper'

describe Channel::VideosImportSpecification do
  let(:spec) { described_class.new(params) }

  describe '#channels' do
    let_it_be(:channel) { create(:channel) }
    let_it_be(:another_channel) { create(:channel) }
    let(:params) { { channel_ids: } }

    context 'when channel_ids is present' do
      let(:channel_ids) { [channel.id] }

      it 'returns channels with specified ids' do
        expect(spec.channels).to eq([channel])
      end
    end

    context 'when channel_ids is blank' do
      let(:channel_ids) { [] }

      it 'returns all channels' do
        expect(spec.channels).to eq([channel, another_channel])
      end
    end
  end

  describe '#satisfy?' do
    context 'when no stageable is specified' do
      let(:params) { {} }

      it 'returns true' do
        expect(spec.satisfy?(double)).to be_truthy
      end
    end

    context 'when stageable is specified' do
      let(:stageable) { create(:episode) }
      let(:stage) { create(:stage, stageable:, code: 'E-1') }
      let(:params) { { stageable_id: stageable.to_global_id } }

      context 'when video title contains stage code' do
        it 'returns true' do
          expect(spec).to be_satisfy(double(title: 'E-1 | COOL'))
        end
      end

      context 'when video title does not contain stage code' do
        it 'returns false' do
          expect(spec).to be_satisfy(double(title: 'E-2 | COOL'))
        end
      end
    end
  end
end
