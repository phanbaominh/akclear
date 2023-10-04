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
              processed_boxes << prev_near_boxes.merge
              prev_near_boxes = WordBoundingBoxList.new
            end

            prev_near_boxes << box
          end
          processed_boxes << prev_near_boxes.merge if prev_near_boxes.present?
          processed_boxes
        end

        def group_words_into_lines(words_bounding_boxes)
          lines_of_words = []
          current_line = WordBoundingBoxList.new
          words_bounding_boxes.each do |box|
            next if box.average_confidence < 70

            if current_line.line_up?(box)
              current_line << box
            else

              lines_of_words << WordBoundingBoxList.new(group_near_words_in_same_line(current_line.sort_by!(&:x),
                                                                                      all_same_line: true))
              current_line = WordBoundingBoxList.new([box])
            end
          end
          if current_line.present?
            lines_of_words << WordBoundingBoxList.new(group_near_words_in_same_line(current_line.sort_by!(&:x),
                                                                                    all_same_line: true))
          end
          lines_of_words
        end
      end
    end
  end
end
