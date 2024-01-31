class Admin::ClearImage::TestRunConfigurationComponent < ApplicationComponent
  attr_reader :test_run

  def post_initialize(configuration: nil, test_run: nil)
    @test_run = test_run
    @configuration = configuration
  end

  def configuration
    @configuration || test_run.configuration || ClearImage::Extracting::Reader::LOCALE_TO_TESSERACT_LANG.keys.map.with_object({}) do |language, lang_to_config|
      lang_to_config[language] = default_config
    end.with_indifferent_access
  end

  def default_config
    ClearImage::Configuration.new.attributes
  end
end
