class ClearImage::BoundingBox
  # rubocop:disable Metrics/ParameterLists
  attr_reader :x, :y, :width, :height

  def initialize(x, y, width = nil, height = nil, x_end: nil, y_end: nil)
    @x = x
    @y = y
    @width = width || (x_end - x + 1)
    @height = height || (y_end - y + 1)
    @x_end = x_end || (x + width - 1)
    @y_end = y_end || (y + height - 1)
  end

  def to_arr
    [x, y, width, height]
  end

  def x_end
    x + width - 1
  end

  def y_end
    y + height - 1
  end

  def dist(other_box)
    (other_box.x - x_end).abs
  end

  def translate(x: 0, y: 0)
    new_box = dup
    new_box.x += x
    new_box.y += y
    new_box
  end

  def inside?(image)
    x >= 0 && y >= 0 && x_end < image.columns && y_end < image.rows
  end

  protected

  attr_writer :x, :y
end
