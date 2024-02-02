class ClearImage
  module Extracting
    class WordProcessor
      class << self
        def group_near_words_in_same_line(words_bounding_boxes, all_same_line: false)
          processed_boxes = []
          prev_near_boxes = WordBoundingBoxList.new
          words_bounding_boxes.each do |box|
            # convert circled number to normal number
            next if box.average_confidence < 20 || box.character_only_word.blank?

            if prev_near_boxes.present? &&
               !prev_near_boxes.near?(box) &&
               (!all_same_line || !prev_near_boxes.overlapping?(box))
              processed_boxes << prev_near_boxes.merge(filter_noise: true)
              prev_near_boxes = WordBoundingBoxList.new
            end

            prev_near_boxes << box
          end
          processed_boxes << prev_near_boxes.merge(filter_noise: true) if prev_near_boxes.present?
          processed_boxes
        end

        def group_words_into_lines(words_bounding_boxes, allowed_box_conf)
          lines_of_words = []
          visited = Array.new(words_bounding_boxes.size, false)
          0.upto(words_bounding_boxes.size - 1) do |i|
            next if visited[i]
            next if words_bounding_boxes[i].average_confidence < allowed_box_conf

            current_line = WordBoundingBoxList.new

            i.upto(words_bounding_boxes.size - 1) do |j|
              next if visited[j]

              box = words_bounding_boxes[j]
              next if box.average_confidence < allowed_box_conf

              if current_line.line_up?(box)
                visited[j] = true
                current_line << box
              end
            end
            current_line = WordBoundingBoxList.new(group_near_words_in_same_line(current_line.sort_by!(&:x),
                                                                                 all_same_line: true))
            lines_of_words << current_line
          end
          lines_of_words
        end
      end
    end
  end
end
