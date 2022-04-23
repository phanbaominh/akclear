# frozen_string_literal: true

class RiskConflictRelation < ApplicationRecord
  belongs_to :risk, inverse_of: :forward_risk_conflict_relations
  belongs_to :conflicted_risk, class_name: 'Risk', inverse_of: :backward_risk_conflict_relations
  validates :risk_id, uniqueness: { scope: :conflicted_risk_id }
end
