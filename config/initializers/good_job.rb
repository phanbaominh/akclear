ActiveSupport.on_load(:good_job_application_controller) do
  # context here is GoodJob::ApplicationController


  before_action do
    authenticate
    raise ActionController::RoutingError, 'Not Found' unless Current.user&.admin?
  end

  def authenticate
    return unless (session_record = Session.find_by_id(cookies.signed[:session_token]))

    Current.session = session_record
  end
end
