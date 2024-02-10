# frozen_string_literal: true

# A list could be a line or a group of words that are near each other

class ClearImage
  module Extracting
    class WordBoundingBoxList
      include Enumerable
      NEAR_ALLOWED_DIFFERENCE = 1
      MOST_COMMON_Y_THRESHOLD = 3
      EVENLY_SPACED_RATIO = 0.5
      delegate :pop, :<<, :present?, :last, :size, :max_by, to: :list
      delegate :near?, :overlapping?, to: :last

      def initialize(list = [])
        @list = list
      end

      def merge(filter_noise: false)
        (filter_noise ? longest_continuous_evenly_spaced_sublist : list).reduce do |merged_box, box|
          merged_box.merge(box)
        end
      end

      def longest_continuous_evenly_spaced_sublist
        dists = dist_between_word_ends(0)
        start = 0
        max_len = 1
        cur_len = 1
        cur_start = 0
        0.upto(dists.size - 2) do |i|
          if Utils.within_ratio?(dists[i], dists[i + 1], EVENLY_SPACED_RATIO)
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

      def dist_between_word_ends(lower_bound)
        list.each_cons(2).filter_map do |first_name_box, second_name_box|
          dist = second_name_box.x_end - first_name_box.x_end
          dist if dist > lower_bound
        end
      end

      def line_up?(box)
        return true if list.empty?

        list.min_by(&:y).y + list.min_by(&:height).height >= box.y || list.min_by(&:y_end).y_end >= box.y
      end

      def most_common_box_y
        return if list.size < MOST_COMMON_Y_THRESHOLD

        result, boxes = list.group_by(&:y).max_by { |_, boxes| boxes.size }
        return if boxes.size < MOST_COMMON_Y_THRESHOLD

        result
      end

      def remove_outlier!
        keep_evenly_wide_boxes
        return unless most_common_box_y

        list.reject! { |box| (box.y - most_common_box_y).abs > 5 }
      end

      def keep_evenly_wide_boxes
        sorted_width_boxes = list.sort_by(&:average_character_width)
        start = 0
        max_len = 0
        cur_start = 0
        cur_len = 1
        0.upto(sorted_width_boxes.size - 2) do |i|
          if Utils.within_ratio?(
            sorted_width_boxes[i].average_character_width, sorted_width_boxes[i + 1].average_character_width, 0.3
          )
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
        kept_boxes = sorted_width_boxes[start...start + max_len]
        list.reject! do |box|
          kept_boxes.exclude?(box)
        end
      end

      def keep_evenly_high_boxes; end

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

      def all_boxes_y=(new_y)
        list.each { |box| box.y = new_y }
      end

      def y
        list.max_by(&:y).y
      end

      def y_end
        list.max_by(&:y_end).y_end
      end

      attr_reader :list
    end
  end
end
