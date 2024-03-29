module Admin
  class ClearFromJobsController < AdminController
    include ClearFilterable
    def new
      @job = ExtractClearDataFromVideoJob.find_by(id: params[:job_id])
      return redirect_to(new_clear_path) unless @job.may_mark_clear_created?

      set_modifying_clear
      @clear = @job.clear
      used_operators_session.init_from_clear(@clear)
      render 'clears/new'
    end
  end
end
