class Admin::VideosImportsController < AdminController
  authorize_resource class: false

  def new
    @spec = Channel::VideosImportSpecification.new(videos_import_params)
  end

  def create
    ImportVideosJob.perform_later(videos_import_params)
    redirect_to admin_clear_jobs_path, notice: I18n.t('admin.videos_imports.create.success')
  end

  private

  def videos_import_params
    return {} if params[:videos_import].blank? && action_name == 'new'

    params.require(:videos_import).permit(:stageable_id, :all_channels, :stage_id, :challenge_mode, :clear_language,
                                          :stage_type, :environment, :full_pages, channel_ids: [])
  end
end
