# frozen_string_literal: true

require 'rails_helper'
require 'contracts/contracts_helper'

describe Risks::CreateContract do
  include_context 'contract'

  describe 'schema' do
    include_examples(
      'schema field', :description,
      required: true,
      valid_value: 'a valid description',
      failures: [
        ['', 'is not filled', 'must be filled']
      ]
    )
    include_examples(
      'schema field', :icon,
      required: true,
      valid_value: (test_file = File.new('tmp')),
      failures: [
        ['a string', 'is not File', 'must be File']
      ]
    ) { test_file.close }
    include_examples(
      'schema field', :level,
      required: true,
      valid_value: 1,
      failures: [
        [4, 'greater than 3', 'must be less than or equal to 3'],
        [0, 'less than 1', 'must be greater than or equal to 1']
      ]
    )
    include_examples(
      'schema field', :contigency_contract_id,
      required: true,
      valid_value: 1,
      failures: [
        [[1], 'is not Integer', 'must be an integer'],
        [nil, 'is not filled', 'must be filled']
      ]
    ) do
      before { create(:contigency_contract, id: 1) }
    end
  end

  describe 'rules' do
    describe 'r.contigency_contract_id' do
      let(:params) { { contigency_contract_id: 1 } }

      context 'when not found' do
        it 'fails' do
          expect(errors[:contigency_contract_id]).to eq(['must exist'])
        end
      end

      context 'when found' do
        let!(:contigency_contract) { create(:contigency_contract, id: 1) }

        it 'succeed' do
          expect(errors[:contigency_contract_id]).to be_nil
        end

        it 'stores contigency contract record in context' do
          expect(context[:contigency_contract]).to eq contigency_contract
        end
      end
    end
  end
end
