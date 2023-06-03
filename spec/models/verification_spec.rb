require 'rails_helper'

RSpec.describe Verification, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:verifier).class_name('User') }
    it { is_expected.to belong_to(:clear) }
  end
end
