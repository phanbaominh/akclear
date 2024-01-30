class Admin::Clear::TestResultSummaryComponent < ApplicationComponent
  attr_reader :test_result

  def post_initialize(test_result:)
    @test_result = test_result
  end

  def status_badge
    test_result.passed? ? 'badge-neutral' : 'badge-error'
  end

  def language
    test_result.language == :'zh-CN' ? 'cn' : test_result.language
  end
end
