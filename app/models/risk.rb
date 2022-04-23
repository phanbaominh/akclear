# frozen_string_literal: true

class Risk < ApplicationRecord
  belongs_to :contigency_contract
  has_many :forward_risk_conflict_relations, class_name: 'RiskConflictRelation', dependent: :destroy
  has_many :forward_conflicted_risks, through: :forward_risk_conflict_relations, source: :conflicted_risk
  has_many(
    :backward_risk_conflict_relations,
    class_name: 'RiskConflictRelation',
    foreign_key: :conflicted_risk_id,
    dependent: :destroy,
    inverse_of: :conflicted_risk
  )
  has_many :backward_conflicted_risks, through: :backward_risk_conflict_relations, source: :risk
end
