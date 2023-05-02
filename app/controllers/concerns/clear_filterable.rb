# frozen_string_literal: true

module ClearFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_clear_spec
  end

  private

  def use_clear_spec_session
    @clear_spec_params = clear_spec_session
  end

  def delete_clear_spec_session
    session['clear_spec_params'] = nil
  end

  def set_clear_spec_session
    session['clear_spec_params'] = clear_spec_params
  end

  def clear_spec_session
    @clear_spec_session ||= (session['clear_spec_params'] ||= {})
  end

  def set_clear_spec
    @clear_spec = Clear::Specification.new(**(clear_spec_params.to_h || {}))
  end

  def clear_spec_from_session
    @clear_spec_from_session ||= Clear::Specification.new(**(clear_spec_session.to_h.symbolize_keys || {}))
  end

  def clear_params
    return {} if params[:clear].nil?

    @clear_params ||= params.require(:clear).permit(:stageable_id, :stage_id, :challenge_mode,
                                                    :operator_id, :link, :name, used_operators_attributes: %i[operator_id elite skill]).compact_blank
  end

  def clear_spec_params
    return clear_params if modifying_clear?
    return @clear_spec_params if @clear_spec_params
    return (@clear_spec_params ||= {}) if params[:clear_specification].nil?

    @clear_spec_params ||= params.require(:clear_specification).permit(:stageable_id, :stage_id, :challenge_mode,
                                                                       :operator_id, used_operators_attributes: %i[operator_id elite skill]).compact_blank
  end
end
