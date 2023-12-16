# frozen_string_literal: true

class Admin::ExtractClearDataFromVideoJobs::ShowComponent < ApplicationComponent
  attr_reader :job

  def post_initialize(job:)
    @job = job
  end

  def status_to_badge_color
    case job.status
    when ExtractClearDataFromVideoJob::FAILED
      'badge-error badge-error-content'
    when ExtractClearDataFromVideoJob::CLEAR_CREATED
      'badge-success badge-success-content'
    when ExtractClearDataFromVideoJob::PENDING
      'badge-warning badge-warning-content'
    else
      'badge-primary badge-primary-content'
    end
  end
end
