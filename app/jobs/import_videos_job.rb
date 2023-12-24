class ImportVideosJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :system
  good_job_control_concurrency_with(
    # need to limit to 1 due to OOM, need to optimize before increasing
    perform_limit: 1,
    key: -> { 'import_videos_job' }
  )

  def perform(spec_params)
    spec = Channel::VideosImportSpecification.new(spec_params.transform_keys(&:to_sym))
    Channel.import_videos_from_channels(spec)
    # Do something later
  end
end
