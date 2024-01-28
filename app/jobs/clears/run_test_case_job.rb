module Clears
  class RunTestCaseJob < ApplicationJob
    queue_as :system

    def perform(test_case_id, test_run_id)
      test_case = Clear::TestCase.find_by(id: test_case_id)

      return if test_case.blank?

      test_run = Clear::TestRun.find_by(id: test_run_id)
      return if test_run.blank? || test_run.finished?

      test_result = Clear::TestResult.new(test_case_id:, test_run_id:)
      test_result.compute!
    end
  end
end
