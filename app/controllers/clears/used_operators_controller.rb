class Clears::UsedOperatorsController < ApplicationController
  skip_before_action :authenticate!
  include ClearFilterable

  def show
    @used_operator = get_used_operator(session['used_operator'])
    session['used_operator'] = nil
    respond_to do |format|
      format.html
      format.turbo_stream # currently only used for exiting from new & edit mode
    end
  end

  def new
    session['used_operator'] = nil
    @used_operator =
      UsedOperator.new(params[:used_operator] ? used_operator_params : {})

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

    @used_operator = UsedOperator.new(used_operator_params)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    clear_spec_session['used_operators_attributes'] ||= {}
    max_index = clear_spec_session['used_operators_attributes'].keys.max.to_i + 1
    clear_spec_session['used_operators_attributes'][max_index.to_s] = used_operator_params
    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @used_operator = UsedOperator.new(used_operator_params)
      end
    end
  end

  def update
    session['used_operator'] = nil
    index = clear_spec_session['used_operators_attributes']&.find do |_key, used_operator|
      used_operator['operator_id'].to_s == used_operator_params[:operator_id]
    end&.first
    clear_spec_session['used_operators_attributes'][index] = used_operator_params if index

    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        get_used_operator
        @has_declined_verification = has_declined_verification?
      end
    end
  end

  def destroy
    clear_spec_session['used_operators_attributes']&.delete_if do |_key, used_operator|
      used_operator['operator_id'] == params[:operator_id]
    end
    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @is_destroy_editing_used_operator = params[:operator_id] == session.dig('used_operator', 'operator_id')
        get_used_operator
      end
    end
  end

  private

  def has_declined_verification?
    return false unless @used_operator.persisted?

    return true if !@used_operator.changed? && @used_operator.verification_declined?

    used_operator_ids_excluding_current =
      clear_spec_session['used_operators_attributes'].values.pluck('id').map(&:to_i) - [@used_operator.id]
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
    params.require(:used_operator).permit(*PERSISTED_OPERATORS_ATTRIBUTES)
  end

  def used_session_keys
    [clear_spec_session_key]
  end
end
