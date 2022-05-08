# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Risk, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:contigency_contract) }
  end
end
