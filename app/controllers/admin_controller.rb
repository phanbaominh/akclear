class AdminController < ApplicationController
  before_action :admin?

  def show; end

  private

  def admin?
    redirect_to root_path unless Current.user.admin?
  end
end
