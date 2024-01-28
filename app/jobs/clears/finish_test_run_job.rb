# frozen_string_literal: true

module Clears
  class FinishTestRunJob < ApplicationJob
    queue_as :system

    def perform(batch, _params)
      test_run = Clear::TestRun.find_by(id: batch.properties[:test_run])

      return if test_run.blank? || test_run.finished?

      test_run.finish!
    end
  end
end
