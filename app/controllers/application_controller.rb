class ApplicationController < ActionController::Base
  around_action :switch_locale

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info { "Access denied on #{exception.action} #{exception.subject}" } if Rails.env.development?
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: exception.message }
    end
  end

  before_action :set_current_request_details
  before_action :authenticate
  before_action :authenticate!

  def current_user
    Current.user
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def authenticate
    return unless (session = Session.find_by_id(cookies.signed[:session_token]))

    Current.session = session
  end

  def authenticate!
    redirect_to sign_in_path, alert: 'You need to sign in or sign up before continuing' unless current_user
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
