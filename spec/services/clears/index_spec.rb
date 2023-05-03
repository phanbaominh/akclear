require 'rails_helper'

describe Clears::Index do
  let(:clear_spec) { Clear::Specification.new(**clear_spec_params) }
  let(:service) { described_class.new(clear_spec) }
  let(:result) { service.call }

  context 'when filtering by stage' do
    let_it_be(:clear_stage_1) { create(:clear, stage: create(:stage, id: 1)) }
    let_it_be(:clear_stage_2) { create(:clear, stage: create(:stage, id: 2)) }
    let(:clear_spec_params) { { stage_id: 1 } }

    it 'returns clears for the given stage' do
      expect(result).to be_success
      expect(result.value!).to contain_exactly(clear_stage_1)
    end
  end

  context 'when filtering by operator_ids' do
    let_it_be(:operator) { create(:operator) }
    let_it_be(:clear_operator_1) { create(:clear, used_operators: [create(:used_operator, operator:)]) }
    let_it_be(:clear_operator_2) { create(:clear, used_operators: [create(:used_operator)]) }
    let(:clear_spec_params) { { used_operators_attributes: { '0' => { operator_id: operator.id } } } }

    it 'returns clears for the given operators' do
      expect(result).to be_success
      expect(result.value!).to contain_exactly(clear_operator_1)
    end
  end

  context 'when filtering by stageable' do
    let_it_be(:episode) { create(:episode, id: 1) }
    let_it_be(:event) { create(:event, id: 1) }
    let_it_be(:episode_clear_1) { create(:clear, stage: create(:stage, stageable: episode)) }
    let_it_be(:episode_clear_2) { create(:clear, stage: create(:stage)) }
    let_it_be(:event_clear) { create(:clear, stage: create(:stage, stageable: event)) }
    let(:clear_spec_params) { { stageable_id: episode.to_global_id.to_s } }

    it 'returns clears for the given stage' do
      expect(result).to be_success
      expect(result.value!).to contain_exactly(episode_clear_1)
    end
  end
end
