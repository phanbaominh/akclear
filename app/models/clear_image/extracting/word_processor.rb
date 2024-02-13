# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity
class ClearImage
  module Extracting
    class WordProcessor
      class << self
        def group_near_words_boxes_matching_detected_words(words_bounding_boxes, words)
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

          result = merge_word_boxes_to_match_detected_words(processed_boxes, words)
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

        private

        def merge_word_boxes_to_match_detected_words(processed_boxes, words)
          processed_boxes.select! do |box|
            words.find { |word| word.include?(box.word) }
          end
          result = []
          current_merged_box = nil
          i = 0
          while i < processed_boxes.size
            previous_merged_box = current_merged_box
            current_merged_box = if current_merged_box
                                   current_merged_box.merge(processed_boxes[i])
                                 else
                                   processed_boxes[i]
                                 end
            if words.find { |word| word == current_merged_box.word }
              result << current_merged_box
              current_merged_box = nil
            elsif !words.find { |word| word.start_with?(current_merged_box.word) }
              result << (previous_merged_box || current_merged_box)
              i -= 1 if previous_merged_box
              current_merged_box = nil
            end
            i += 1
          end
          result << current_merged_box if current_merged_box
          result
        end
      end
    end
  end
end

# rubocop:enable Metrics/PerceivedComplexity
