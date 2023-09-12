module Admin
  class ExtractClearDataFromVideoJobsController < ApplicationController
    # load and authorized @extract_clear_data_from_video_job and @extract_clear_data_from_video_jobs
    load_and_authorize_resource

    def index; end

    def new
      @extract_clear_data_from_video_job = ExtractClearDataFromVideoJob.new
    end

    def create
      if @extract_clear_data_from_video_job.save
        @extract_clear_data_from_video_job.start!
        redirect_to admin_clear_jobs_path, notice: I18n.t('admin.extract_clear_data_from_video_jobs.create.success')
      else
        render :new
      end
    end

    def destroy
      if @extract_clear_data_from_video_job.destroy
        redirect_to admin_clear_jobs_path, notice: I18n.t('admin.extract_clear_data_from_video_jobs.destroy.success')
      end
    end

    private

    def extract_clear_data_from_video_job_params
      params.require(:extract_clear_data_from_video_job).permit(:video_url)
    end
  end
end
