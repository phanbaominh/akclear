# frozen_string_literal: true

module ClearFilterable
  extend ActiveSupport::Concern

  PERSISTED_CLEAR_ATTRIBUTES = %i[stage_id link name channel_id id].freeze

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

  def set_clear_spec_session_from_params
    session['clear_params'] = clear_params

    return unless session['clear_params']['used_operators_attributes']

    @used_operators_session = UsedOperatorsSession.new([])
    session['clear_params']['used_operators_attributes'].each_value do |used_operator_params|
      @used_operators_session.add(used_operator_params)
    end

    session['clear_params']['used_operators_attributes'] = @used_operators_session.data
  end

  def clear_spec_session_key
    'clear_params'
  end

  def clear_spec_session
    @clear_spec_session ||= session[clear_spec_session_key] || init_used_session_key(clear_spec_session_key, {})
  end

  def init_clear_spec_session_from_existing_clear
    return unless params[:id]
    return if session[clear_spec_session_key] && session[clear_spec_session_key]['id']

    clear = Clear.find(params[:id])

    init_used_session_key(clear_spec_session_key, clear.attributes.symbolize_keys.slice(
                                                    *PERSISTED_CLEAR_ATTRIBUTES
                                                  ))
    used_operators_session.init_from_clear(clear)
  end

  def delete_clear_spec_session_of_existing_clear
    delete_clear_spec_session if session[clear_spec_session_key] && session[clear_spec_session_key]['id']
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
    @clear_spec = clear_from_attributes
  end

  def reset_stage_spec_if_needed
    return if @clear_spec&.stage_type&.constantize == @clear_spec&.stageable&.class

    @clear_spec.reset_spec
  end

  def clear_from_attributes
    if (clear = clear_from_id)
      clear.assign_attributes(clear_spec_attributes)
      clear
    else
      Clear.new(clear_spec_attributes || {})
    end
  end

  def clear_spec_attributes
    @use_clear_spec_param ? clear_params.to_h : (clear_spec_session || {}).symbolize_keys
  end

  def clear_params
    return {} if params[:clear].nil? && %w[update create].exclude?(action_name)

    @clear_params ||= params.require(:clear).permit(
      :stageable_id, :stage_id, :challenge_mode, :stage_type, :environment, :job_id,
      :operator_id, :link, :name, :channel_id, :self_only, :favorited, stage_ids: [],
                                                                       used_operators_attributes: UsedOperatorsSession::PERSISTED_OPERATORS_ATTRIBUTES + [:_destroy]
    ).compact_blank
  end

  def clear_from_id
    Clear.find_by(id: params[:id])
  end

  def used_operators_session
    return @used_operators_session if @used_operators_session

    clear_spec_session['used_operators_attributes'] ||= []

    @used_operators_session ||= UsedOperatorsSession.new(clear_spec_session['used_operators_attributes'])
  end
end
