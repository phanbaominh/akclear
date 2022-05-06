# frozen_string_literal: true

module Risks
  class ConflictedRisks
    include Dry::Monads[:do, :result, :try]

    def initialize(risk)
      @risk = risk
    end

    def get
      base_scope =
        Risk.left_outer_joins(:forward_risk_conflict_relations).left_outer_joins(:backward_risk_conflict_relations)
      base_scope
        .where(forward_risk_conflict_relations: { conflicted_risk: risk })
        .or(base_scope.where(backward_risk_conflict_relations: { risk: }))
    end

    def add(conflicted_risk)
      return Failure(:self_conflict) if conflicted_risk == risk

      current_conflicted_risks = get

      if current_conflicted_risks.exists?(id: conflicted_risk.id)
        Failure(:existing_conflict)
      else
        Try { risk.forward_conflicted_risks << conflicted_risk }.to_result.bind { Success(risk) }
      end
    end

    def remove(conflicted_risk)
      Try do
        RiskConflictRelation
          .where(risk:, conflicted_risk:)
          .or(RiskConflictRelation.where(conflicted_risk: risk, risk: conflicted_risk))
          .first
          .destroy
      end.to_result.bind do |destroyed_result|
        destroyed_result ? Success(destroyed_result) : Failure(:not_destroyed)
      end
    end

    private

    attr_reader :risk
  end
end
