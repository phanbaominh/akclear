# frozen_string_literal: true

module Clears
  class Index < ::ApplicationService
    param :spec, type: Types.Instance(Clear)

    def call
      @clears = base_scope
      hide_rejected_clears
      filter_by_self
      filter_by_favorited
      filter_by_verification_status
      filter_by_stageable
      filter_by_stage
      filter_by_operators
      filter_by_channel
      Success(@clears)
    end

    private

    def base_scope
      Clear.all
    end

    def hide_rejected_clears
      return if spec.self_only

      @clears = @clears.not_rejected
    end

    def filter_by_verification_status
      return unless spec.verification_status

      @clears = @clears.joins(:verification).where(verifications: { status: spec.verification_status })
    end

    def filter_by_favorited
      return unless spec.favorited

      @clears = @clears.where(id: @clears.joins(:likes).where(likes: { user_id: Current.user.id }))
    end

    def filter_by_self
      return unless spec.self_only

      @clears = @clears.where(submitter_id: Current.user.id)
    end

    def filter_by_channel
      return if spec.channel_id.blank?

      @clears = @clears.where(channel_id: spec.channel_id)
    end

    def filter_by_stage
      return if spec.stage_id.blank?

      @clears = @clears.where(stage_id: spec.stage_id)
    end

    def filter_by_operators
      return if spec.used_operators.empty?

      @clears = @clears.joins(:used_operators).distinct
      @clears = @clears.where(id: UsedOperator
        .where(used_operators: { operator_id: spec.used_operators.map(&:operator_id) })
        .group(:clear_id)
        .having('count(*) = ?', spec.used_operators.size)
        .pluck(:clear_id))
    end

    def filter_by_stageable
      return if spec.stage_id.present? || spec.stageable.blank?

      @clears = @clears.joins(:stage).where(stages: { stageable: spec.stageable })
    end
  end
end
