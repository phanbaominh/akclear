class ClearImage
  module Extracting
    class Processor
      class << self
        include Magick

        def make_names_white_on_black(image, floodfill_x: nil, floodfill_y: nil)
          floodfill_x ||= image.columns / 2
          floodfill_y ||= image.rows / 2
          image
            .quantize(2, GRAYColorspace) # greyscale
            .negate_channel(false, RedChannel, GreenChannel, BlueChannel) # invert color so that names are white and bg black
            .color_floodfill(floodfill_x, floodfill_y, white_pixel) # remove black color as much as possible
            .tap { |i| i.alpha(OffAlphaChannel) } # remove alpha
        end

        def paint_white_over_non_names(image, first_name_line_bounding_box, second_name_line_bounding_box)
          first_non_name_bounding_box =
            (if first_name_line_bounding_box.y > 0
               BoundingBox.new(0, 0, image.columns,
                               y_end: first_name_line_bounding_box.y - 1)
             end)
          second_non_name_bounding_box = BoundingBox.new(
            0, first_name_line_bounding_box.y_end + 1, image.columns, y_end: second_name_line_bounding_box.y - 1
          )
          last_non_name_bounding_box = (if second_name_line_bounding_box.y_end < image.rows
                                          BoundingBox.new(
                                            0, second_name_line_bounding_box.y_end + 1, image.columns, y_end: image.rows - 1
                                          )
                                        end)
          [first_non_name_bounding_box, second_non_name_bounding_box,
           last_non_name_bounding_box].compact.reduce(image) do |result_image, bounding_box|
            fill_bounding_box_with_target_color(result_image, bounding_box, white_pixel)
          end
        end

        def make_characters_sharper(image)
          image.unsharp_mask(6.8, 1, 2.69, 0).reduce_noise(0)
        end

        private

        def fill_bounding_box_with_target_color(image, bounding_box, pixel)
          x, y, columns, rows = bounding_box.to_arr
          pixels = image.get_pixels(x, y, columns, rows).map { pixel }
          image.store_pixels(x, y, columns, rows, pixels)
        end

        def white_pixel
          Pixel.from_color('white')
        end
      end
    end
  end
end
