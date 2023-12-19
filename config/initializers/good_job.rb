ActiveSupport.on_load(:good_job_application_controller) do
  # context here is GoodJob::ApplicationController

  before_action do
    raise ActionController::RoutingError, 'Not Found' unless current_user&.admin?
  end
end
