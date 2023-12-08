class ApplicationController < ActionController::Base
  include TurboFlashable
  # check_authorization TODO: enable this and add skip authorization for public pages
  around_action :switch_locale

  rescue_from CanCan::AccessDenied do |exception|
    if Rails.env.production?
      not_found
      return
    end

    Rails.logger.info { "Access denied on #{exception.action} #{exception.subject}" } if Rails.env.development?
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: exception.message }
    end
  end

  before_action :manage_session_keys
  before_action :set_current_request_details
  before_action :authenticate
  before_action :authenticate!

  def current_user
    Current.user
  end

  private

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def authenticate
    return unless (session_record = Session.find_by_id(cookies.signed[:session_token]))

    Current.session = session_record
  end

  def authenticate!
    redirect_to sign_in_path, alert: t('sign_in_redirect') unless current_user
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  # TODO: move to concern session key logic

  def manage_session_keys
    slate_keys_to_be_deleted
    keep_used_session_keys
    delete_unused_keys
  end

  def init_used_session_key(key, value)
    session['deleting'] ||= {}
    session['deleting'][key] ||= true
    session[key] = value
  end

  def delete_unused_keys
    return if session['deleting'].blank?

    session['deleting'].each do |key, value|
      next unless value

      p "Deleting #{key}"
      session.delete(key)
      session['deleting'].delete(key)
    end
  end

  def keep_used_session_keys
    return if session['deleting'].blank?

    used_session_keys.each do |key|
      session['deleting'][key] = false
    end
  end

  def slate_keys_to_be_deleted
    return if session['deleting'].blank?

    session['deleting'].each_key do |key|
      session['deleting'][key] = true
    end
  end

  def used_session_keys
    []
  end
end
