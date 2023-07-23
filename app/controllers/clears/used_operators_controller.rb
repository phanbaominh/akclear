class Clears::UsedOperatorsController < ApplicationController
  skip_before_action :authenticate!
  include ClearFilterable

  def new
    @used_operator =
      UsedOperator.new(params[:used_operator] ? used_operator_params : {})

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

  def destroy
    clear_spec_session['used_operators_attributes']&.delete_if do |_key, used_operator|
      used_operator['operator_id'] == params[:operator_id]
    end
    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @used_operator = UsedOperator.new(operator_id: params[:operator_id])
      end
    end
  end

  def edit
    @used_operator = UsedOperator.new(used_operator_params)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    index = clear_spec_session['used_operators_attributes']&.find do |_key, used_operator|
      used_operator['operator_id'] == used_operator_params[:operator_id]
    end&.first
    clear_spec_session['used_operators_attributes'][index] = used_operator_params if index

    respond_to do |format|
      format.html { redirect_to clears_operators_select_path(clear: clear_spec_session) }
      format.turbo_stream do
        set_clear_spec
        @used_operator = UsedOperator.new(used_operator_params)
        render :create
      end
    end
  end

  private

  def used_operator_params
    params.require(:used_operator).permit(:operator_id, :clear_id, :level, :elite, :skill_level, :skill_mastery, :skill)
  end
end
