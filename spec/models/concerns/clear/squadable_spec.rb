require 'rails_helper'

describe Clear::Squadable do
  let_it_be(:clear, reload: true) { create(:clear) }

  describe 'associations' do
    subject { clear }

    it { is_expected.to have_many(:used_operators).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:used_operators).allow_destroy(true) }
  end

  describe 'validations' do
    let_it_be(:used_operator) do
      create(:used_operator, clear:)
    end

    it 'calls validation on squad' do
      clear.used_operators.build(operator_id: used_operator.operator_id)

      expect(clear).to be_invalid
      expect(clear.errors[:used_operators]).to include('is already in squad')
    end
  end
end
