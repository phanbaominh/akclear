module Admin
  class ExtractClearDataFromVideoJobsController < AdminController
    include Pagy::Backend
    # load and authorized @extract_clear_data_from_video_job and
    # @extract_clear_data_from_video_jobs (ExtracClearDataFromVideoJob.accessible_by(current_ability)
    load_and_authorize_resource

    before_action :redirect_if_job_started, only: %i[edit update]

    def index
      @job_spec = ExtractClearDataFromVideoJob.new(filter_params)
      @pagy, @extract_clear_data_from_video_jobs =
        pagy(
          @extract_clear_data_from_video_jobs.satisfy(@job_spec).order(created_at: :desc).includes(stage: :stageable), items: 10
        )
    end

    def show; end

    def new
      @extract_clear_data_from_video_job = ExtractClearDataFromVideoJob.new
    end

    def edit; end

    def create
      if @extract_clear_data_from_video_job.save
        @extract_clear_data_from_video_job.start!

        respond_to do |format|
          format.html do
            redirect_to admin_clear_jobs_path,
                        notice: I18n.t('admin.extract_clear_data_from_video_jobs.create.success')
          end
          format.turbo_stream
        end
      else
        render :new
      end
    end

    def update
      if @extract_clear_data_from_video_job.update(extract_clear_data_from_video_job_params)
        @extract_clear_data_from_video_job.start!
        respond_to do |format|
          format.html do
            redirect_to admin_clear_jobs_path,
                        notice: I18n.t('admin.extract_clear_data_from_video_jobs.update.success')
          end
          format.turbo_stream
        end
      else
        render :edit
      end
    end

    def destroy
      return unless @extract_clear_data_from_video_job.destroy

      respond_to do |format|
        format.html do
          redirect_to admin_clear_jobs_path,
                      notice: I18n.t('admin.extract_clear_data_from_video_jobs.destroy.success')
        end
        format.turbo_stream
      end
    end

    private

    def redirect_if_job_started
      return if @extract_clear_data_from_video_job.pending?

      redirect_to admin_clear_jobs_path, alert: I18n.t('admin.extract_clear_data_from_video_jobs.job_started')
    end

    def filter_params
      return {} unless params.key?(:extract_clear_data_from_video_job)

      params.require(:extract_clear_data_from_video_job).permit(:status).tap do |filter_params|
        filter_params[:status] = filter_params[:status].present? ? filter_params[:status].to_i : nil
      end
    end

    def extract_clear_data_from_video_job_params
      params.require(:extract_clear_data_from_video_job).permit(:video_url, :stage_id)
    end
  end
end
