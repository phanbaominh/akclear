require 'rails_helper'

describe User::Verifiable do
  describe '#verify' do
    it 'destroys all existing clear reports' do
      clear = create(:clear)
      verifier = create(:user)
      create(:report, clear:)

      verifier.verify(clear, { status: 'accepted' })

      expect(clear.reports).to be_empty
    end
  end
end
