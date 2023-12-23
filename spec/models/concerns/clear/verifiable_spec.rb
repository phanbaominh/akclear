require 'rails_helper'

describe Clear::Verifiable do
  describe 'need verification' do
    let_it_be(:unverified_with_no_channel_clear_1) { create(:clear, channel: nil) }
    let_it_be(:reported_verified_clear) { create(:clear, :verified) }
    let_it_be(:reported_unverified_clear) { create(:clear) }
    let_it_be(:clear) { create(:clear) }
    let_it_be(:verified_clear) { create(:clear, :verified) }
    let_it_be(:unverified_clear) { create(:clear) }
    let_it_be(:unverified_with_no_channel_clear_2) { create(:clear, channel: nil) }

    before_all do
      create(:report, clear: reported_verified_clear)
      create(:report, clear: reported_unverified_clear)
    end

    describe '#next_unverified' do
      it 'returns the next unverified clear' do
        expect(clear.next_unverified).to eq(unverified_clear)
        expect(unverified_clear.next_unverified).to be_blank
      end
    end

    describe '#prev_unverified' do
      it 'returns the previous unverified clear or verified reported clear' do
        expect(clear.prev_unverified).to eq(reported_unverified_clear)
        expect(reported_unverified_clear.prev_unverified).to eq(reported_verified_clear)
        expect(reported_verified_clear.prev_unverified).to be_blank
      end
    end
  end

  describe '.not_rejected' do
    let_it_be(:rejected_clear) { create(:clear, :rejected) }
    let_it_be(:verified_clear) { create(:clear, :verified) }
    let_it_be(:unverified_clear) { create(:clear) }

    it 'returns not rejected clears' do
      expect(Clear.not_rejected).to contain_exactly(verified_clear, unverified_clear)
    end
  end
end
