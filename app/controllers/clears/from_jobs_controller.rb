module Clears
  class FromJobsController < ApplicationController
    include ClearFilterable
    def new
      @job = ExtractClearDataFromVideoJob.find_by(id: params[:job_id])
      return redirect_to(new_clear_path) unless @job.completed?

      set_modifying_clear
      @clear = @job.clear
      render 'clears/new'
    end
  end
end
