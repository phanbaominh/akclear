class ClearImage
  module Extracting
    class WordBoundingBox < BoundingBox
      NON_CHARACTERS_REGEX = /[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}ー-]+/u

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

      def near?(other_box)
        largest_possible_distance_between_character =
          [average_character_width,
           other_box.average_character_width].min * Configuration.max_character_distance_to_width_ratio_to_be_near
        dist(other_box) <= largest_possible_distance_between_character
      end

      def overlapping?(other_box)
        x_end >= other_box.x
      end

      def near_end?(image)
        y_end + (1 * height) >= image.rows
      end

      def average_character_width
        width * 1.0 / word.length
      end

      def average_confidence
        confidence.is_a?(Array) ? confidence.sum * 1.0 / confidence.size : confidence
      end

      def valid?
        !(average_confidence < 20 || character_only_word.blank?)
      end

      def inspect
        "word: #{word}, x: #{x}, y: #{y}, x_end: #{x_end}, y_end: #{y_end}, width: #{width}, height: #{height},char_w: #{average_character_width}, confidence: #{confidence}
        , parts: xs: #{parts.map(&:x)} ys: #{parts.map(&:y)}"
      end
    end
  end
end
