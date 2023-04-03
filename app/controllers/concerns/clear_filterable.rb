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
    return {} if params[:clear].nil?

    clear_spec_params = params.require(:clear).permit(:stageable, :stage_id, :challenge_mode, operator_ids: [])
    stageable_id, stageable_type =
      clear_spec_params[:stageable].present? ? JSON.parse(clear_spec_params[:stageable]) : []
    clear_spec_params[:operator_ids]
    clear_spec_params.merge!(stageable_type:, stageable_id:).compact_blank!
  end
end
