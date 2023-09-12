module Admin
  class ExtractClearDataFromVideoJobsController < ApplicationController
    # load and authorized @extract_clear_data_from_video_job and @extract_clear_data_from_video_jobs
    load_and_authorize_resource

    before_action :redirect_if_job_started, only: %i[edit update]

    def index; end

    def new
      @extract_clear_data_from_video_job = ExtractClearDataFromVideoJob.new
    end

    def edit; end

    def create
      if @extract_clear_data_from_video_job.save
        @extract_clear_data_from_video_job.start!
        redirect_to admin_clear_jobs_path, notice: I18n.t('admin.extract_clear_data_from_video_jobs.create.success')
      else
        render :new
      end
    end

    def update
      if @extract_clear_data_from_video_job.update(extract_clear_data_from_video_job_params)
        @extract_clear_data_from_video_job.start!
        redirect_to admin_clear_jobs_path, notice: I18n.t('admin.extract_clear_data_from_video_jobs.update.success')
      else
        render :edit
      end
    end

    def destroy
      return unless @extract_clear_data_from_video_job.destroy

      redirect_to admin_clear_jobs_path, notice: I18n.t('admin.extract_clear_data_from_video_jobs.destroy.success')
    end

    private

    def redirect_if_job_started
      return if @extract_clear_data_from_video_job.pending?

      redirect_to admin_clear_jobs_path, alert: I18n.t('admin.extract_clear_data_from_video_jobs.job_started')
    end

    def extract_clear_data_from_video_job_params
      params.require(:extract_clear_data_from_video_job).permit(:video_url)
    end
  end
end
