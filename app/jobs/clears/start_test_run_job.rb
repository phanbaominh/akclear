module Clears
  class StartTestRunJob < ApplicationJob
    queue_as :system

    def perform(test_run_id)
      test_run = ClearImage::TestRun.find_by(id: test_run_id)
      return if test_run.blank? || test_run.started?

      test_run.start!

      GoodJob::Batch.enqueue(on_finish: FinishTestRunJob, test_run:) do
        (test_run.test_case_ids || ClearImage::TestCase.pluck(:id)).each do |test_case_id|
          RunTestCaseJob.perform_later(test_case_id, test_run.id)
        end
      end
    end
  end
end
