require 'rails_helper'

RSpec.describe RiskConflictRelation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:risk).inverse_of(:forward_risk_conflict_relations) }
    it { is_expected.to belong_to(:conflicted_risk).class_name('Risk').inverse_of(:backward_risk_conflict_relations) }
  end

  describe 'validations' do
    subject { build(:risk_conflict_relation) }

    it { is_expected.to validate_uniqueness_of(:risk_id).scoped_to(:conflicted_risk_id) }
  end
end
