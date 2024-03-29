# frozen_string_literal: true

class ClearImage
  module Extracting
    class WordBoundingBox < BoundingBox
      NON_CHARACTERS_REGEX = /[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}\p{Hangul}ー-]+/u

      attr_reader :word, :confidence, :parts

      def initialize(ocr_result)
        super ocr_result[:x_start], ocr_result[:y_start], x_end: ocr_result[:x_end], y_end: ocr_result[:y_end]
        @word = ocr_result[:word]
        @confidence = ocr_result[:confidence]
        @parts = ocr_result[:parts] || [self]
      end

      def merge(other_box)
        self.class.new(
          {
            x_start: [x, other_box.x].min,
            y_start: [y, other_box.y].min,
            x_end: [x_end, other_box.x_end].max,
            y_end: [y_end, other_box.y_end].max,
            word: word + other_box.word,
            confidence: [confidence, other_box.confidence].flatten,
            parts: [parts, other_box.parts].flatten
          }
        )
      end

      def character_only_word
        @character_only_word ||= @word.gsub(NON_CHARACTERS_REGEX, '')
      end

      def near_jp?(other_box, lined_up: false)
        return false if lined_up && (y - other_box.y).abs >= 10
        return true if lined_up && overlapping?(other_box)

        widths = [average_character_width, other_box.average_character_width]

        return false if widths.min * 2 < widths.max

        largest_possible_distance_between_character = widths.max

        dist(other_box) <= largest_possible_distance_between_character
      end

      def near?(other_box, lined_up: false)
        return near_jp?(other_box, lined_up:) if Reader.jp?

        largest_possible_distance_between_character =
          [average_character_width,
           other_box.average_character_width].min * Configuration.max_character_distance_to_width_ratio_to_be_near
        dist(other_box) <= largest_possible_distance_between_character # && (!lined_up || (y - other_box.y).abs < 10)
      end

      def overlapping?(other_box)
        x_end > other_box.x && x < other_box.x_end
      end

      def near_edge?(image)
        near_end = y_end + (1 * height) >= image.rows
        near_start = y < (image.rows / 3.0)
        near_end || near_start
      end

      def average_character_width
        return width * 1.0 / word.length if parts.size == 1 || !Reader.jp?

        i = 0
        part_character_widths = []
        while i < parts.size
          j = i + 1
          overlapped_word = parts[i].word
          while j < parts.size && parts[i].overlapping?(parts[j])
            overlapped_word += parts[j].word
            j += 1
          end
          part_character_widths << (parts[i].width / overlapped_word.length.to_f)
          i = j
        end

        part_character_widths.sum / part_character_widths.size.to_f
      end

      def relative_word_length
        if Reader.en? || Reader.jp?
          word.length
        else
          alphanumeric_char_size = word.chars.count { |c| c.match?(/[a-zA-Z0-9-]/) }
          word.length - (alphanumeric_char_size / 2.0)
        end
      end

      def average_confidence
        confidence.is_a?(Array) ? confidence.sum * 1.0 / confidence.size : confidence
      end

      def trust
        @confidence = [100]
      end

      def dist_between_word_end(other_box)
        (x_end - other_box.x_end).abs
      end

      def inspect
        "word: #{word}, x: #{x}, y: #{y}, x_end: #{x_end}, y_end: #{y_end}, width: #{width}, height: #{height},char_w: #{average_character_width}, confidence: #{confidence}
        , parts: xs: #{parts.map(&:x)} ys: #{parts.map(&:y)}"
      end
    end
  end
end
