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
