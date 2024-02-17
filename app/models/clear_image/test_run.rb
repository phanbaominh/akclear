# frozen_string_literal: true

class ClearImage::TestRun < ApplicationRecord
  self.table_name = 'clear_test_runs'

  STATUSES = [
    STARTED = :started,
    FINISHED = :finished
  ]

  attr_reader :test_count

  attribute :all, :boolean, default: false
  attribute :latest_size, :integer, default: 5

  attribute :languages, default: -> { Channel.clear_languages.keys.map(&:to_s) }

  def test_cases
    @test_cases ||= ClearImage::TestCase.where(id: test_case_ids)
  end

  def test_count=(value)
    @test_count = value.to_i
    return unless value

    self.test_case_ids = ClearImage::TestCase.take(@test_count).pluck(:id)
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
    super || (@all_test_case_ids ||= ClearImage::TestCase.pluck(:id))
  end

  def study
    self.test_case_ids =
      ClearImage::TestCase.where(id: test_case_ids)
                          .joins(clear: :channel).where(channels: { clear_language: languages }).pluck(:id)
  end

  def test_results
    @test_results ||= ClearImage::TestCase.where(id: test_case_ids).pluck(:id).map do |test_case_id|
      test_result = ClearImage::TestResult.new(test_case_id:, test_run: self)
      test_result
    end
  end

  def all=(value)
    super
    self.test_case_ids = ClearImage::TestCase.pluck(:id) if all?
  end

  def get_test_result(test_case_or_id)
    test_case_id = test_case_or_id.id if test_case_or_id.is_a?(ClearImage::TestCase)
    result = test_results.find do |test_result|
      test_result.test_case_id == test_case_id
    end
    result.test_case = test_case_or_id if result && test_case_or_id.is_a?(ClearImage::TestCase)
    result
  end

  def latest_test_runs
    @latest_test_runs ||= ClearImage::TestRun.where.not(id:)
                                             .where('test_case_ids @> ARRAY[?]::bigint[]', test_case_ids).where('id < ?', id).order(id: :desc).limit(latest_size).to_a
  end

  def prev_test_run_id(test_case_id: nil)
    scope = ClearImage::TestRun.where('id < ?', id).order(id: :desc).limit(1)
    scope = scope.where('test_case_ids @> ARRAY[?]::bigint[]', test_case_id) if test_case_id
    scope.pick(:id)
  end

  def next_test_run_id(test_case_id: nil)
    scope = ClearImage::TestRun.where('id > ?', id).order(id: :asc).limit(1)
    scope = scope.where('test_case_ids @> ARRAY[?]::bigint[]', test_case_id) if test_case_id
    scope.pick(:id)
  end
end
