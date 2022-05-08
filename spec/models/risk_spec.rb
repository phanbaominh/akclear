# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Risk, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:contingency_contract) }
  end
end
