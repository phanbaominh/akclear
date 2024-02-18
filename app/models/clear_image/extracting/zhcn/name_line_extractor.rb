# frozen_string_literal: true

class ClearImage
  module Extracting
    module Zhcn
      class NameLineExtractor < ClearImage::Extracting::NameLineExtractor
        private

        def extract_word_lines(lined_up: false)
          word_lines = super
          word_lines.reject! do |line|
            line.reject! do |box|
              next false if box.word.include?('X')

              box.word =~ /\p{Latin}+/ && box.word =~ /\p{Han}+/
            end
            line.empty?
          end
          word_lines
        end

        def group_near_word_bounding_boxes(word_bounding_boxes, lined_up, psm)
          word_bounding_boxes.reject! do |box|
            box.word =~ /LV\d+/ || box.word =~ /M\d+/ || box.word =~ /^\d+\w{0,1}/
          end

          word_bounding_boxes =
            if lined_up
              words = reader.read_lined_names_text(tmp_file_path, psm:)
              Extracting::WordProcessor.group_near_words_boxes_matching_detected_words(word_bounding_boxes, words)
            else
              Extracting::WordProcessor.group_near_words_in_same_line(word_bounding_boxes)
            end
          word_bounding_boxes.reject { |box| box.word =~ /star/i || box.word =~ /快捷编队/ }
        end
      end
    end
  end
end
