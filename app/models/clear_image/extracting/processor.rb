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
          first_line, second_line = [first_name_line_bounding_box, second_name_line_bounding_box].map do |line|
            [get_line(image, line), get_line(image, line, reverse: true)]
          end

          first_non_name_bounding_box =
            (if first_line[0] > 0
               BoundingBox.new(0, 0, image.columns,
                               y_end: first_line[0] - 1)
             end)
          second_non_name_bounding_box = BoundingBox.new(
            0, first_line[1] + 3, image.columns, y_end: second_line[0] - 1
          )
          underline_1 = BoundingBox.new(0, first_line[1] + 1, image.columns, 1)
          last_non_name_bounding_box = (if second_line[0] < image.rows
                                          BoundingBox.new(
                                            0, second_line[1] + 1, image.columns, y_end: image.rows - 1
                                          )
                                        end)
          underline_2 = BoundingBox.new(0, second_line[1] + 3, image.columns, 1)
          tmp = [first_non_name_bounding_box, second_non_name_bounding_box,
                 last_non_name_bounding_box]
                .compact.reduce(image) do |result_image, bounding_box|
            fill_bounding_box_with_target_color(result_image, bounding_box, white_pixel)
          end
          [underline_1, underline_2].reduce(tmp) do |result_image, underline|
            fill_bounding_box_with_target_color(result_image, underline, Pixel.from_color('black'))
          end
        end

        def paint_white_in_between_names(image, first_name_line_bounding_box, second_name_line_bounding_box)
          [*get_inbetween_boxes(first_name_line_bounding_box),
           *get_inbetween_boxes(second_name_line_bounding_box)].reduce(image) do |result_image, bounding_box|
            fill_bounding_box_with_target_color(result_image, bounding_box, white_pixel)
          end
        end

        def make_characters_sharper(image)
          image.unsharp_mask(6.8, 1, 2.69, 0).reduce_noise(0)
        end

        private

        def get_inbetween_boxes(line)
          line.each_cons(2).map do |first_box, second_box|
            BoundingBox.new(first_box.x_end + 1, first_box.y, second_box.x - first_box.x_end - 1, first_box.height)
          end
        end

        def get_line(image, line_bounding_box, reverse: false)
          line_bounding_box.parts.map do |part|
            get_last_white_line(image, part, reverse:)
          end.send(reverse ? :max : :min)
        end

        def get_last_white_line(image, box, reverse: false)
          width = box.width
          c = 0
          has_black = false
          prev_white_line = nil
          l = reverse ? box.height - 1 : 0
          pixels = image.get_pixels(*box.to_arr)
          pixels = pixels.reverse if reverse
          pixels.each do |pixel|
            if c >= width
              c = 0
              break if has_black && prev_white_line

              prev_white_line = l unless has_black
              reverse ? l -= 1 : l += 1
              has_black = false
            end
            has_black ||= pixel.to_color != 'white'
            c += 1
          end
          box.y + l
        end

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