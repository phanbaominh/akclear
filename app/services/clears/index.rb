# frozen_string_literal: true

module Clears
  class Index < ::ApplicationService
    param :spec, type: Types.Instance(Clear::Specification)

    def call
      @clears = base_scope
      filter_by_stageable
      filter_by_stage
      filter_by_operators
      Success(@clears)
    end

    private

    def base_scope
      Clear.all
    end

    def filter_by_stage
      return if spec.stage_id.blank?

      @clears = @clears.where(stage_id: spec.stage_id)
    end

    def filter_by_operators
      return if spec.operator_ids.empty?

      @clears = @clears.joins(:used_operators).where(used_operators: { operator_id: spec.operator_ids }).distinct
    end

    def filter_by_stageable
      return if spec.stage_id.present? || spec.stageable.blank?

      @clears = @clears.joins(:stage).where(stages: { stageable: spec.stageable })
    end
  end
end
