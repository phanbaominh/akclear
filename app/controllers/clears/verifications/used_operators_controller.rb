class Clears::Verifications::UsedOperatorsController < ApplicationController
  load_and_authorize_resource :clear
  authorize_resource :verification
  load_resource :used_operator, through: :clear

  def edit; end

  def update
    session['verification_used_operators'] ||= { clear_id: params[:clear_id] }
    session['verification_used_operators'][@used_operator.id] = used_operator_params[:verification_status]

    redirect_to new_clear_verification_path(@clear)
  end

  private

  def used_operator_params
    params.require(:used_operator).permit(:verification_status)
  end

  def used_session_keys
    %w[verification_used_operators]
  end
end
