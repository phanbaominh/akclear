class ClearImage
  include Extractable
  include TmpFileStorable

  def initialize(path)
    @path = path
    Logger.dir_path_for_current_thread = path.parent.to_s
  end

  def used_operators_data
    @used_operators_data ||= extract
  end

  private

  attr_reader :path

  def image
    @image ||= Magick::ImageList.new(path.to_s)
  end
end
