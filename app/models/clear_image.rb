class ClearImage
  include Extractable
  include TmpFileStorable

  def initialize(image_path, data_path = nil, options = {})
    @image_path = image_path
    @data_path = data_path
    Logger.dir_path_for_current_thread = data_path.to_s
    Configuration.for_current_thread = options
  end

  def used_operators_data
    @used_operators_data ||= extract
  end

  private

  attr_reader :image_path, :data_path

  def image
    @image ||= Magick::ImageList.new(image_path.to_s)
  end
end
