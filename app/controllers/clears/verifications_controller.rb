class Clears::VerificationsController < ApplicationController
  load_resource :clear
  authorize_resource class: false

  def create
    flash[:error] = I18n.t(:failed_to_verify) unless current_user.verify(@clear)

    respond_to do |format|
      format.html { redirect_to clear_path(@clear) }
      format.turbo_stream
    end
  end

  def destroy
    flash[:error] = I18n.t(:failed_to_unverify) unless current_user.unverify(@clear)

    @clear.reload

    respond_to do |format|
      format.html { redirect_to clear_path(@clear) }
      format.turbo_stream { render :create }
    end
  end
end
