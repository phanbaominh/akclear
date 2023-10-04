class ClearImage
  include Extractable
  # include TmpFileStorable

  def initialize(path)
    @path = path
  end

  def used_operators_data
    @used_operators_data ||= extract
  end

  private

  attr_reader :path

  def image
    @image ||= Magick::ImageList.new(path)
  end
end
