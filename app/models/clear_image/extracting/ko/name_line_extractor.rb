# frozen_string_literal: true

class ClearImage
  module Extracting
    module Ko
      class NameLineExtractor < ClearImage::Extracting::NameLineExtractor
        private

        def group_near_word_bounding_boxes(word_bounding_boxes, lined_up, psm)
          result = if lined_up
                     words = reader.read_lined_names_text(tmp_file_path, psm:)
                     Extracting::WordProcessor.group_near_words_boxes_matching_detected_words(word_bounding_boxes,
                                                                                              words)
                   else
                     Extracting::WordProcessor.group_near_words_in_same_line(word_bounding_boxes)
                   end
          result.reject { |box| box.word =~ /빠른편성/ }
        end
      end
    end
  end
end
