# frozen_string_literal: true

module ClearFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_clear_spec
  end

  private

  def set_clear_spec
    @clear_spec = Clear::Specification.new(**(clear_spec_params.to_h || {}))
  end

  def clear_spec_params
    return {} if params[:clear_specification].nil?

    params.require(:clear_specification).permit(:stageable_id, :stage_id, :challenge_mode,
                                                operator_ids: []).compact_blank
  end
end
