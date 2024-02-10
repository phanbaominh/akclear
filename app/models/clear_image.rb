class ClearImage
  include Extractable
  include TmpFileStorable

  def initialize(image_path, options = {}, log_data_path: nil, language: nil)
    @image_path = image_path
    @log_data_path = log_data_path
    Logger.dir_path_for_current_thread = log_data_path.to_s
    Configuration.for_current_thread = options
    Extracting::Reader.language = language
  end

  def used_operators_data
    @used_operators_data ||= extract
  end

  private

  attr_reader :image_path, :log_data_path

  def image
    @image ||= Magick::ImageList.new(image_path.to_s)
  end
end
