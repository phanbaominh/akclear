module ApplicationHelper
  def flash_key_to_alert_class(key)
    {
      notice: 'alert-info',
      alert: 'alert-warning',
      success: 'alert-success'
    }[key.to_sym]
  end
end
