class Clears::LikesController < ApplicationController
  authorize_resource class: false

  def create
    @clear = Clear.find(params[:clear_id])
    Current.user.like(@clear)

    respond_to do |format|
      format.html { redirect_to @clear }
      format.turbo_stream
    end
  end

  def destroy
    @clear = Clear.find(params[:clear_id])
    Current.user.unlike(@clear)

    respond_to do |format|
      format.html { redirect_to @clear }
      format.turbo_stream { render :create }
    end
  end
end
