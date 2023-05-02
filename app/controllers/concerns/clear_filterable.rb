# frozen_string_literal: true

module ClearFilterable
  extend ActiveSupport::Concern

  included do
    before_action :assign_modifying_clear
  end

  private

  def use_clear_spec_param
    @use_clear_spec_param = true
  end

  def delete_clear_spec_session
    session[clear_spec_session_key] = nil
  end

  def set_clear_spec_session
    session['clear_spec_params'] = clear_spec_params
  end

  def clear_spec_session_key
    modifying_clear? ? 'clear_params' : 'clear_spec_params'
  end

  def clear_spec_session
    @clear_spec_session ||= session[clear_spec_session_key]
  end

  def assign_modifying_clear
    @modifying_clear = session['modifying_clear']
  end

  def set_modifying_clear
    session['modifying_clear'] = true
  end

  def unset_modifying_clear
    session['modifying_clear'] = nil
  end

  def modifying_clear?
    session['modifying_clear']
  end

  def set_clear_spec
    @clear_spec = if modifying_clear?
                    Clear.new(clear_spec_attributes || {})
                  else
                    Clear::Specification.new(**(clear_spec_attributes || {}))
                  end
  end

  def clear_spec_attributes
    @use_clear_spec_param ? clear_spec_params.to_h : (clear_spec_session || {}).symbolize_keys
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
