module ApplicationHelper
  def flash_key_to_alert_class(key)
    {
      notice: 'alert-info',
      alert: 'alert-warning',
      success: 'alert-success',
      error: 'alert-error'
    }[key.to_sym]
  end

  def flash_key_to_icon_class(key)
    {
      notice: 'information-circle',
      alert: 'exclamation-triangle',
      success: 'check-circle',
      error: 'x-circle'
    }[key.to_sym]
  end

  def current_user
    Current.user
  end

  def time_string(time)
    "#{time_ago_in_words(time)} #{I18n.t(:ago)}"
  end

  def by_string(performer_name)
    "#{I18n.t(:by)} #{performer_name}"
  end

  def authenticated?
    Current.user.present?
  end

  def latest_unverified_clear
    @latest_unverified_clear ||= Clear.need_verification.first
  end
end
