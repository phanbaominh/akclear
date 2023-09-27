# frozen_string_literal: true

class Admin::ExtractClearDataFromVideoJobs::ShowComponent < ApplicationComponent
  attr_reader :job

  def post_initialize(job:)
    @job = job
  end
end
