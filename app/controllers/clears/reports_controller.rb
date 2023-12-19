class Clears::ReportsController < ApplicationController
  load_and_authorize_resource :clear
  authorize_resource :report, class: false

  def create
    if Current.user.report(@clear)
      respond_to do |format|
        format.html { redirect_to @clear, notice: t('.success') }
        format.turbo_stream { flash.now[:notice] = t('.success') }
      end
    else
      redirect_to @clear, alert: t('.failed')
    end
  end

  def destroy
    if Current.user.unreport(@clear)
      respond_to do |format|
        format.html { redirect_to @clear, notice: t('.success') }
        format.turbo_stream do
          flash.now[:notice] = t('.success')
          render :create
        end
      end
    else
      redirect_to @clear, alert: t('.failed')
    end
  end
end
