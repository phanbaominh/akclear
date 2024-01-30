class Admin::Clear::TestRunCorrectRatioComponent < ApplicationComponent
  attr_reader :test_result

  def post_initialize(test_result: nil, correct_ratio: nil, max_latest_correct_ratio: nil)
    @test_result = test_result
    @max_latest_correct_ratio = max_latest_correct_ratio
    @correct_ratio = correct_ratio
  end

  def correct_ratio
    @correct_ratio ||= test_result.correct_ratio
  end

  def max_latest_correct_ratio
    @max_latest_correct_ratio ||= test_result.max_latest_correct_ratio
  end

  def correct_ratio_diff_class
    difference = correct_ratio_diff

    if difference.positive?
      'badge-success'
    elsif difference.zero?
      'badge-neutral'
    else
      'badge-error'
    end
  end

  def correct_ratio_diff
    @correct_ratio_diff ||= correct_ratio - max_latest_correct_ratio
  end
end
