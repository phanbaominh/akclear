# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Risk, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:contigency_contract) }
    it { is_expected.to have_many(:forward_risk_conflict_relations).class_name('RiskConflictRelation').dependent(:destroy) }
    it { is_expected.to have_many(:forward_conflicted_risks).through(:forward_risk_conflict_relations).source(:conflicted_risk) }

    it do
      is_expected.to(
        have_many(:backward_risk_conflict_relations)
          .class_name('RiskConflictRelation')
          .with_foreign_key(:conflicted_risk_id)
          .dependent(:destroy)
          .inverse_of(:conflicted_risk)
      )
    end

    it { is_expected.to have_many(:backward_conflicted_risks).through(:backward_risk_conflict_relations).source(:risk) }
  end
end
