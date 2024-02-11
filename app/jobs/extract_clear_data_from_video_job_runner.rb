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
    job = ExtractClearDataFromVideoJob.find_by(id: job_id)

    # TODO: handle possible race condition if more than 1 job performed at the same time
    return unless job&.started?

    job.process!

    case Clears::BuildClearFromVideo.call(job.video, operator_name_only: job.operator_name_only,
                                                     language: job.channel&.clear_language)
    in Success(clear)
      job.data = {
        stage_id: job.stage_id,
        link: clear.link,
        used_operators_attributes: clear.used_operators.map(&:attributes),
        channel_id: job.channel_id,
        name: job.data&.dig('name')
      }
      job.complete!
    in Failure(error)
      job.data ||= {}
      job.data[:error] = error
      job.fail!
    end
  rescue StandardError => e
    job.data ||= {}
    job.data[:error] = e.message
    job.fail!
  end
end
