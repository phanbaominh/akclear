# frozen_string_literal: true

class Admin::ExtractClearDataFromVideoJobs::ShowComponent < ApplicationComponent
  attr_reader :job

  def initialize(job)
    @job = job
  end
end
