class Clears::UsedOperatorsController < ApplicationController
  skip_before_action :authenticate!
  include ClearFilterable

  def show
    load_squad
    @used_operator = get_used_operator(session['used_operator'])
    session['used_operator'] = nil
    respond_to do |format|
      format.html
      format.turbo_stream # currently only used for exiting from new & edit mode
    end
  end

  def new
    session['used_operator'] = {}
    @used_operator =
      squad.add(params[:used_operator] ? used_operator_params : {})

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @previous_used_operator = UsedOperator.new(session['used_operator'])
    # keep track of used operator to return to when exit
    has_changed_used_operator = session['used_operator']&.dig('operator_id') != used_operator_params[:operator_id]
    session['used_operator'] = used_operator_params if has_changed_used_operator

    @used_operator = squad.add(used_operator_params)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    session['used_operator'] = nil
    squad.add(used_operator_params)
    unless squad.valid?
      return flash_stream(status: :unprocessable_entity, type: 'alert', msg: squad.errors.full_messages.first)
    end

    new_params = used_operators_session.add(used_operator_params)

    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @used_operator = UsedOperator.new(new_params)
      end
    end
  end

  def update
    session['used_operator'] = nil

    used_operators_session.update(used_operator_params)
    load_squad

    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        get_used_operator
        @submit_btn_disabled = has_declined_verification?
      end
    end
  end

  def destroy
    used_operators_session.remove(used_operator_params[:operator_id])
    load_squad

    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @is_destroy_editing_used_operator = used_operator_params[:operator_id] == session.dig('used_operator',
                                                                                              'operator_id')
        @is_operator_form_active = session['used_operator'] && !@is_destroy_editing_used_operator
        get_used_operator
      end
    end
  end

  private

  def squad
    @squad ||= Squad.new(used_operators_attributes: used_operators_session.data)
  end
  alias load_squad squad

  def max_used_operators?
    clear_spec_session['used_operators_attributes'].size >= Squad::MAX_USED_OPERATORS
  end

  def has_declined_verification?
    return false unless @used_operator.persisted?

    return true if !@used_operator.changed? && @used_operator.verification_declined?

    used_operator_ids_excluding_current =
      clear_spec_session['used_operators_attributes'].pluck('id').map(&:to_i) - [@used_operator.id]
    UsedOperatorVerification.exists?(
      used_operator_id: used_operator_ids_excluding_current,
      status: Verification::DECLINED
    )
  end

  def get_used_operator(used_params = used_operator_params)
    return if used_params.blank?

    @used_operator = used_params['id'].present? ? UsedOperator.find(used_params['id']) : UsedOperator.new
    @used_operator.assign_attributes(used_params)
    @used_operator
  end

  def clear_from_id
    params[:used_operator] && used_operator_params[:clear_id] && Clear.find_by(id: used_operator_params[:clear_id])
  end

  def used_operator_params
    params.require(:used_operator).permit(*UsedOperatorsSession::PERSISTED_OPERATORS_ATTRIBUTES)
  end

  def used_session_keys
    [clear_spec_session_key, 'used_operator']
  end
end
