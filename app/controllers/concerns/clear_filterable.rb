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
    session['clear_params'] = clear_params
  end

  def clear_spec_session_key
    'clear_params'
  end

  def clear_spec_session
    @clear_spec_session ||= (session[clear_spec_session_key] ||= {})
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
    @clear_spec = Clear.new(clear_spec_attributes || {})
    return unless @clear_spec&.stage_type&.constantize != @clear_spec&.stageable&.class

    @clear_spec.reset_spec
  end

  def clear_spec_attributes
    @use_clear_spec_param ? clear_params.to_h : (clear_spec_session || {}).symbolize_keys
  end

  def clear_params
    return {} if params[:clear].nil?

    @clear_params ||= params.require(:clear).permit(:stageable_id, :stage_id, :challenge_mode, :stage_type, :environment,
                                                    :operator_id, :link, :name, used_operators_attributes: %i[operator_id elite skill]).compact_blank
  end
end
