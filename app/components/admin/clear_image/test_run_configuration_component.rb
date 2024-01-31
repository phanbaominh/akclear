class Admin::ClearImage::TestRunConfigurationComponent < ApplicationComponent
  attr_reader :test_run

  def post_initialize(test_run:)
    @test_run = test_run
  end
end
