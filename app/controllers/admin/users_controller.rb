class Admin::UsersController < ApplicationController
  include Pagy::Backend
  load_and_authorize_resource

  def index
    @user_spec = User.new(user_params)
    @pagy, @users = pagy(@users.satisfy(@user_spec).order(created_at: :desc))
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to admin_user_path(@user), notice: t('.success') }
        format.turbo_stream { render }
      end
    else
      flash.now[:alert] = t('.failed')
      render :edit
    end
  end

  private

  def user_params
    return {} if action_name == 'index' && params[:user].blank?

    @user_params = params.require(:user).permit(:role)
  end
end
