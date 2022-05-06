# frozen_string_literal: true

require 'rails_helper'
require 'support/monad_helper'

describe Risks::ConflictedRisks do
  let_it_be(:risk) { create(:risk) }
  let(:conflicted_risks) { described_class.new(risk) }

  describe '#get' do
    let_it_be(:forward_conflicted_risk) { create(:risk) }
    let_it_be(:backward_conflicted_risk) { create(:risk) }
    let_it_be(:unrelated_risk) { create(:risk) }

    before_all do
      create(:risk_conflict_relation, risk:, conflicted_risk: forward_conflicted_risk)
      create(:risk_conflict_relation, risk: backward_conflicted_risk, conflicted_risk: risk)
    end

    let(:result) { conflicted_risks.get }

    it { expect(result).to contain_exactly(forward_conflicted_risk, backward_conflicted_risk) }
  end

  describe '#add' do
    let_it_be(:added_risk) { create(:risk) }
    let(:result) { conflicted_risks.add(added_risk) }

    context 'when adding an existing conflicted risk' do
      before { create(:risk_conflict_relation, risk: added_risk, conflicted_risk: risk) }

      it 'fails', :aggregate_failures do
        expect(result).not_to be_success
        expect(result.failure).to eq(:existing_conflict)
      end
    end

    context 'when adding a new conflicted risk' do
      context 'when no unexpected error' do
        it 'succeed', :aggregate_failures do
          expect(result).to be_success
          expect(risk.conflicted_risks.get).to contain_exactly(added_risk)
        end
      end

      context 'when unexpected error' do
        include_examples 'handling exception' do
          before { allow(risk).to receive(:forward_conflicted_risks).and_raise(exception) }
        end
      end
    end

    context 'when adding self' do
      let_it_be(:added_risk) { risk }

      it 'fails', :aggregate_failures do
        expect(result).not_to be_success
        expect(result.failure).to eq(:self_conflict)
      end
    end
  end

  describe '#remove' do
    let_it_be(:removed_risk) { create(:risk) }
    let(:result) { conflicted_risks.remove(removed_risk) }

    before { create(:risk_conflict_relation, risk:, conflicted_risk: removed_risk) }

    context 'when is conflicted risk' do
      it 'succeed', :aggregate_failures do
        expect(result).to be_success
        expect(risk.conflicted_risks.get).to be_empty
      end
    end

    context 'when conflicted risk is not removed' do
      before { allow_any_instance_of(RiskConflictRelation).to receive(:destroy).and_return(false) }

      it 'fails', :aggregate_failures do
        expect(result).not_to be_success
        expect(result.failure).to eq(:not_destroyed)
      end
    end

    context 'when unexpected error happen' do
      include_examples 'handling exception' do
        before { allow_any_instance_of(RiskConflictRelation).to receive(:destroy).and_raise(exception) }
      end
    end
  end
end
