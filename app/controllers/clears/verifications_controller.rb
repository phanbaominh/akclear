class Clears::VerificationsController < ApplicationController
  def create
    clear = Clear.find(params[:clear_id])

    flash[:error] = I18n.t(:failed_to_verify) unless current_user.verify(clear)

    respond_to do |format|
      format.html { redirect_to clear_path(clear) }
    end
  end

  def destroy
    clear = Clear.find(params[:clear_id])

    flash[:error] = I18n.t(:failed_to_unverify) unless current_user.unverify(clear)

    respond_to do |format|
      format.html { redirect_to clear_path(clear) }
    end
  end
end
