class ExtractClearDataFromVideoJobRunner < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  include Dry::Monads[:result]
  queue_as :system_serial
  good_job_control_concurrency_with(
    # need to limit to 1 due to OOM, need to optimize before increasing
    perform_limit: 1,
    key: -> { 'extract_clear_data_from_video_job' }
  )

  def perform(job_id)
    # TODO: handle retries
    job = ExtractClearDataFromVideoJob.find_by(id: job_id)

    # TODO: handle possible race condition if more than 1 job performed at the same time
    return unless job&.started?

    job.process!

    job.extract_from_video

    job.error? ? job.fail! : job.complete!
  rescue StandardError => e
    job.data ||= {}
    job.data['error'] = e.message
    job.fail!
  end
end
