class ExtractClearDataFromVideoJobRunner < ApplicationJob
  include Dry::Monads[:result]
  queue_as :system

  def perform(job_id)
    job = ExtractClearDataFromVideoJob.find_by(id: job_id)

    return unless job&.started?

    job.process!

    case Clears::BuildClearFromVideo.call(job.video)
    in Success(clear)
      job.data = {
        stage_id: clear.stage_id,
        link: clear.link,
        used_operators_attributes: clear.used_operators.map(&:attributes)
      }
      job.complete!
    in Failure(error)
      job.data = { error: }
      job.fail!
    end
  rescue StandardError => e
    job.data = { error: e.message }
    job.fail!
  end
end
