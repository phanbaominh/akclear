module Clears
  class FromJobsController < ApplicationController
    include ClearFilterable
    def new
      @job = ExtractClearDataFromVideoJob.find_by(id: params[:job_id])
      set_modifying_clear
      @clear = @job.clear
      render 'clears/new'
    end
  end
end
