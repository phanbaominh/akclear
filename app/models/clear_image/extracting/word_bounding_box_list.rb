# frozen_string_literal: true

# A list could be a line or a group of words that are near each other

class ClearImage
  module Extracting
    class WordBoundingBoxList
      include Enumerable
      NEAR_ALLOWED_DIFFERENCE = 1
      delegate :pop, :<<, :present?, :last, :size, :max_by, to: :list
      delegate :near?, :overlapping?, to: :last

      def initialize(list = [])
        @list = list
      end

      #       [
      #     #<ClearImage::Extracting::WordBoundingBoxList:0x000000010b44d5e8 @list=[word: リナール, x: 153, y: 325, x_end: 76, y_end: 33, width: 76, height: 33, confidence: [96, 96, 96, 96]
      #         , parts: xs: [153, 170, 191, 211] ys: [330, 329, 325, 330], word: タバルト, x: 308, y: 325, x_end: 76, y_end: 30, width: 76, height: 30, confidence: [96, 96, 96, 96]
      #         , parts: xs: [308, 328, 346, 364] ys: [329, 325, 325, 329], word: ラヴァ, x: 483, y: 325, x_end: 60, y_end: 33, width: 60, height: 33, confidence: [96, 88, 96]
      #         , parts: xs: [483, 503, 521] ys: [329, 325, 325], word: ミッドナイト, x: 584, y: 329, x_end: 109, y_end: 19, width: 109, height: 19, confidence: [96, 96, 96, 96, 96, 96]
      #         , parts: xs: [584, 604, 624, 640, 659, 682] ys: [336, 334, 329, 330, 330, 330], word: ブプリュム, x: 771, y: 324, x_end: 77, y_end: 34, width: 77, height: 34, confidence: [77, 76, 96, 96, 97]
      #         , parts: xs: [771, 782, 792, 811, 830] ys: [328, 324, 330, 334, 331], word: ヵシャ, x: 948, y: 307, x_end: 59, y_end: 53, width: 59, height: 53, confidence: [96, 96, 73]
      #         , parts: xs: [948, 970, 986] ys: [329, 307, 307]]>,
      #     #<ClearImage::Extracting::WordBoundingBoxList:0x000000010b445de8 @list=[word: 冠ビスカス, x: 143, y: 615, x_end: 86, y_end: 42, width: 86, height: 42, confidence: [47, 91, 96, 85, 96]
      #         , parts: xs: [143, 170, 182, 197, 213] ys: [620, 619, 615, 620, 621], word: クルース, x: 308, y: 615, x_end: 88, y_end: 31, width: 88, height: 31, confidence: [96, 97, 96, 96]
      #         , parts: xs: [308, 328, 346, 367] ys: [619, 615, 615, 620], word: カーディ, x: 464, y: 614, x_end: 78, y_end: 32, width: 78, height: 32, confidence: [96, 96, 93, 95]
      #         , parts: xs: [464, 484, 502, 520] ys: [618, 614, 614, 614], word: メランサ, x: 616, y: 618, x_end: 78, y_end: 18, width: 78, height: 18, confidence: [96, 96, 96, 96]
      #         , parts: xs: [616, 636, 657, 675] ys: [619, 619, 623, 618], word: フェン, x: 791, y: 619, x_end: 57, y_end: 16, width: 57, height: 16, confidence: [90, 96, 96]
      #         , parts: xs: [791, 812, 832] ys: [619, 623, 623]]>
      # ]

      # Third name lines
      # [
      #     #<ClearImage::Extracting::WordBoundingBoxList:0x0000000118175638 @list=[word: ムリナール, x: 130, y: 318, x_end: 99, y_end: 30, width: 99, height: 30, confidence: [96, 92, 96, 96, 92]
      #         , parts: xs: [130, 153, 171, 192, 213] ys: [330, 330, 329, 337, 318], word: カタバルト, x: 288, y: 318, x_end: 96, y_end: 30, width: 96, height: 30, confidence: [71, 96, 96, 96, 96]
      #         , parts: xs: [288, 312, 338, 348, 371] ys: [329, 329, 330, 318, 318], word: ラヴァ, x: 483, y: 318, x_end: 56, y_end: 30, width: 56, height: 30, confidence: [96, 95, 61]
      #         , parts: xs: [483, 504, 525] ys: [331, 329, 318], word: ミッドナイト, x: 584, y: 314, x_end: 112, y_end: 47, width: 112, height: 47, confidence: [96, 96, 96, 96, 96, 96]
      #         , parts: xs: [584, 602, 624, 641, 659, 677] ys: [330, 334, 329, 330, 318, 314], word: プリュム, x: 771, y: 328, x_end: 77, y_end: 20, width: 77, height: 20, confidence: [76, 96, 96, 97]
      #         , parts: xs: [771, 792, 811, 830] ys: [328, 330, 334, 331], word: カシャ, x: 948, y: 318, x_end: 55, y_end: 30, width: 55, height: 30, confidence: [91, 95, 37]
      #         , parts: xs: [948, 968, 989] ys: [329, 318, 322]]>,
      #     #<ClearImage::Extracting::WordBoundingBoxList:0x0000000118174580 @list=[word: 琴縄トハイビスカス, x: 0, y: 606, x_end: 229, y_end: 42, width: 229, height: 42, confidence: [34, 49, 49, 96, 97, 96, 97, 95, 96]
      #         , parts: xs: [0, 36, 96, 126, 144, 162, 177, 195, 213] ys: [618, 606, 620, 620, 606, 619, 621, 620, 621], word: クルース, x: 308, y: 619, x_end: 75, y_end: 18, width: 75, height: 18, confidence: [96, 97, 96, 96]
      #         , parts: xs: [308, 328, 347, 367] ys: [619, 619, 626, 620], word: カーティ, x: 464, y: 618, x_end: 74, y_end: 18, width: 74, height: 18, confidence: [96, 96, 80, 96]
      #         , parts: xs: [464, 484, 503, 525] ys: [618, 625, 619, 621], word: メランサ, x: 615, y: 618, x_end: 79, y_end: 25, width: 79, height: 25, confidence: [96, 96, 96, 96]
      #         , parts: xs: [615, 638, 657, 677] ys: [619, 619, 619, 618], word: フェン, x: 791, y: 619, x_end: 57, y_end: 25, width: 57, height: 25, confidence: [93, 96, 90]
      #         , parts: xs: [791, 812, 832] ys: [619, 623, 619]]>
      # ]

      def merge(filter_noise: false)
        (filter_noise ? get_largest_boundary : list).reduce do |merged_box, box|
          merged_box.merge(box)
        end
      end

      def get_largest_boundary
        dists = dists_between_words(0)
        start = 0
        max_len = 1
        cur_len = 1
        cur_start = 0
        0.upto(dists.size - 2) do |i|
          if Utils.within_ratio?(dists[i], dists[i + 1], 0.5)
            cur_len += 1
          else
            if cur_len > max_len
              max_len = cur_len
              start = cur_start
            end
            cur_len = 1
            cur_start = i + 1
          end
        end
        if cur_len > max_len
          max_len = cur_len
          start = cur_start
        end
        list[start..start + max_len]
      end

      def filter_out_noises(estimated_dist, max_x)
        checked = Array.new(list.size, false)
        max_result = WordBoundingBoxList.new
        sorted_list = list.sort_by(&:x)
        sorted_list.each_with_index do |box, index|
          result = WordBoundingBoxList.new([box])
          next if checked[index]

          checked[index] = true
          while (box = box.translate(x: estimated_dist)).x_end < max_x
            next_index = sorted_list.find_index do |other_box|
              Utils.within_ratio?(box.x_end, other_box.x_end, 0.1)
            end
            next unless next_index

            checked[next_index] = true
            result << sorted_list[next_index]
            box = sorted_list[next_index]
          end

          max_result = result if result.size > max_result.size
        end
        max_result
      end

      def dists_between_words(lower_bound)
        list.each_cons(2).filter_map do |first_name_box, second_name_box|
          dist = second_name_box.x_end - first_name_box.x_end
          dist if dist > lower_bound
        end
      end

      def line_up?(box)
        return true if list.empty?

        list.min_by(&:y).y + list.min_by(&:height).height >= box.y || list.min_by(&:y_end).y_end >= box.y
      end

      def each(&)
        list.each(&)
      end

      def +(other)
        new_list = self.class.new(list.dup)
        other.each { |box| new_list << box }
        new_list
      end

      def sort_by!(&)
        list.sort_by!(&)
        self
      end

      def y=(new_y)
        list.each { |box| box.y = new_y }
      end

      attr_reader :list
    end
  end
end
