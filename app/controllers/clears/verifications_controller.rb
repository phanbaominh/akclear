class Clears::VerificationsController < ApplicationController
  load_and_authorize_resource :clear
  before_action :redirect_to_edit, only: %i[new]
  load_and_authorize_resource :verification, through: :clear, singleton: true
  skip_load_resource :verification, only: %i[create]

  def new
    build_used_operator_verifications_from_session
    @verification.used_operator_verifications = @used_operator_verifications
    @verification.clear = @clear
  end

  def edit
    build_used_operator_verifications_from_session
    @verification.used_operator_verifications = @used_operator_verifications
    @verification.clear = @clear
    render 'new'
  end

  def create
    session['verification_used_operators'] = nil
    unless current_user.verify(@clear, verification_params.to_h)
      flash[:alert] = t('.failed_to_verify')
      return redirect_to new_clear_verification_path(@clear)
    end

    respond_to do |format|
      format.html do
        if (other_unverified_clear = @clear.other_unverified)
          redirect_to new_clear_verification_path(other_unverified_clear), flash: { success: t('.success') }
        else
          redirect_to root_path, notice: t('.finished')
        end
      end
    end
  end

  def update
    session['verification_used_operators'] = nil
    unless current_user.verify(@clear, verification_params.to_h)
      flash[:alert] = t('.failed_to_verify')
      return redirect_to edit_clear_verification_path(@clear)
    end

    respond_to do |format|
      format.html do
        redirect_to clear_path(@clear), flash: { success: t('.success') }
      end
    end
  end

  # deprecated, use accepted/rejected status now
  def destroy
    unless current_user.unverify(@clear)
      flash[:alert] = I18n.t(:failed_to_unverify)
      return redirect_to new_clear_verification_path(@clear)
    end

    @clear.reload

    respond_to do |format|
      format.html { redirect_to clear_path(@clear) }
      format.turbo_stream { render :create }
    end
  end

  private

  def redirect_to_edit
    redirect_to edit_clear_verification_path(@clear) if @clear.verified?
  end

  def build_used_operator_verifications_from_session
    unless session.dig('verification_used_operators', 'clear_id') == params[:clear_id].to_s
      init_used_session_key('verification_used_operators', { clear_id: params[:clear_id] })
    end

    @verification.used_operator_verifications.each do |verification|
      session['verification_used_operators'][verification.used_operator_id.to_s] ||= verification.status
    end

    @used_operators = @clear.used_operators.includes(:operator, :verification)

    @used_operator_verifications = @used_operators.filter_map do |used_op|
      status = session['verification_used_operators'][used_op.id.to_s]
      if status
        used_op.verification.present? ? used_op.verification.assign_attributes(status:) : used_op.build_verification(status:)
      end
      used_op.verification
    end
  end

  def used_session_keys
    ['verification_used_operators']
  end

  def verification_params
    params.require(:verification).permit(:status, :comment,
                                         used_operator_verifications_attributes: %i[status used_operator_id id])
  end
end
