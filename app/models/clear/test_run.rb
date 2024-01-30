# frozen_string_literal: true

class Clear::TestRun < ApplicationRecord
  self.table_name = 'clear_test_runs'

  STATUSES = [
    STARTED = :started,
    FINISHED = :finished
  ]

  attr_reader :test_count

  attribute :all, :boolean, default: true

  def test_cases
    @test_cases ||= Clear::TestCase.where(id: test_case_ids)
  end

  def test_count=(value)
    @test_count = value.to_i
    return unless value

    self.test_case_ids = Clear::TestCase.take(@test_count).pluck(:id)
  end

  def data_folder_path
    @data_folder_path ||= Rails.public_path.join('tmp', 'clear_test_runs', id.to_s)
  end

  def started?
    data.present?
  end

  def finished?
    data[:status].present?
  end

  def start!
    data[:status] = STARTED
    save!
  end

  def data
    super || {}
  end

  def finish!
    data[:success_count] = test_results.count(&:passed?)
    data[:failed_count] = test_results.count(&:failed?)
    data[:status] = FINISHED
    save!
  end

  def test_case_ids
    super || (@all_test_case_ids ||= Clear::TestCase.pluck(:id))
  end

  def test_results
    @test_results ||= test_case_ids.map do |test_case_id|
      test_result = Clear::TestResult.new(test_case_id:, test_run: self)
      test_result
    end
  end

  def get_test_result(test_case_or_id)
    test_case_id = test_case_or_id.id if test_case_or_id.is_a?(Clear::TestCase)
    result = test_results.find do |test_result|
      test_result.test_case_id == test_case_id
    end
    result.test_case = test_case_or_id if result && test_case_or_id.is_a?(Clear::TestCase)
    result
  end

  def latest_test_runs
    @latest_test_runs ||= Clear::TestRun.where.not(id:).order(id: :desc).limit(5).to_a
  end
end
