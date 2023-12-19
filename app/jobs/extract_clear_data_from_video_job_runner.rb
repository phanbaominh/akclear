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
