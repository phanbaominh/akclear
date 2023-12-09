class Clears::Verifications::UsedOperatorsController < ApplicationController
  load_and_authorize_resource :clear
  load_resource :used_operator, through: :clear
  before_action :authorize_verification!

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(@used_operator, partial: 'edit',
                                                                  locals: { used_operator: @used_operator, clear: @clear })
      end
    end
  end

  def update
    session['verification_used_operators'] ||= { 'clear_id' => params[:clear_id] }
    session['verification_used_operators'][@used_operator.id.to_s] = used_operator_params[:verification_status]

    respond_to do |format|
      format.html { redirect_to new_clear_verification_path(@clear) }
      format.turbo_stream do
        verification_attrs = session['verification_used_operators'].dup
        @verification = Verification.new(clear_id: verification_attrs.delete('clear_id'))
        @verification.used_operator_verifications = verification_attrs.map do |used_operator_id, status|
          UsedOperatorVerification.new(used_operator_id:, status:)
        end

        status = used_operator_params[:verification_status]
        if @used_operator.verification
          @used_operator.verification.assign_attributes(status:)
        else
          @used_operator.build_verification(status:)
        end
      end
    end
  end

  private

  def authorize_verification!
    authorize!(:create, Verification)
  end

  def used_operator_params
    params.require(:used_operator).permit(:verification_status)
  end

  def used_session_keys
    %w[verification_used_operators]
  end
end
