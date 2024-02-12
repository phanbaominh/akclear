class ClearImage
  module Extracting
    class WordProcessor
      class << self
        def group_based_on_read_words(words_bounding_boxes, words)
          processed_boxes = []
          prev_near_boxes = WordBoundingBoxList.new
          words_bounding_boxes.each do |box|
            next if box.character_only_word.blank?

            if prev_near_boxes.present? &&
               !prev_near_boxes.near?(box)
              (processed_boxes << prev_near_boxes.merge)
              prev_near_boxes = WordBoundingBoxList.new
            end

            prev_near_boxes << box
          end
          processed_boxes << prev_near_boxes.merge if prev_near_boxes.present?
          ap processed_boxes
          processed_boxes.select! do |box|
            words.find { |word| word.include?(box.word) }
          end
          result = [] # processed_boxes
          cur = nil
          0.upto(processed_boxes.size - 1) do |i|
            prev_cur = cur
            cur = if cur
                    cur.merge(processed_boxes[i])
                  else
                    processed_boxes[i]
                  end
            if words.find { |word| word == cur.word }
              result << cur
              cur = nil
            elsif !words.find { |word| word.start_with?(cur.word) }
              result << (prev_cur || cur)
              i -= 1 if prev_cur
              cur = nil
            end
          end
          result << cur if cur
          ap result
          result.each(&:trust)
          result
        end

        def group_near_words_in_same_line(words_bounding_boxes, all_same_line: false)
          processed_boxes = []
          prev_near_boxes = WordBoundingBoxList.new
          words_bounding_boxes.each do |box|
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
