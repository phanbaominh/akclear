class Admin::UsersController < ApplicationController
  include Pagy::Backend
  load_and_authorize_resource

  def index
    @pagy, @users = pagy(@users.order(created_at: :desc))
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: t('.success')
    else
      flash.now[:alert] = t('.failed')
      render :edit
    end
  end

  private

  def user_params
    return @user_params if @user_params

    @user_params = params.require(:user).permit(:role)
    @user_params[:role] = @user_params[:role].to_i
    @user_params
  end
end
