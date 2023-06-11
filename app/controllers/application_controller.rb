class ApplicationController < ActionController::Base
  around_action :switch_locale

  before_action :set_current_request_details
  before_action :authenticate

  def current_user
    Current.user
  end

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def authenticate
    if (session = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session
    else
      redirect_to sign_in_path
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
