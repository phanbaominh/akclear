# rubocop:disable Metrics/ClassLength
class ClearImage
  module Extracting
    class OperatorCardBoundingBox
      BASE_WIDTH = 185.0
      BASE_HEIGHT = 409.0
      BASE_DIST_FROM_START_X_TO_END_X_OF_NAME = 180.0
      BASE_DIST_FROM_START_Y_TO_START_Y_OF_NAME = 375.0
      COMPONENTS = [
        SKILL = :skill,
        LEVEL = :level,
        ELITE = :elite,
        NAME = :name
      ].freeze
      COMPONENTS_TO_BASE_BOUNDING_BOXES = {
        # x, y, width, height
        SKILL => BoundingBox.new(125.0, 315.0, 53.0, 53.0),
        LEVEL => BoundingBox.new(7.0, 319.0, 58.0, 42.0), # [11.0, 328.0, 50.0, 34.0]]
        ELITE => BoundingBox.new(0, 239.0, 75.0, 62.0),
        NAME => BoundingBox.new(0, 373, BASE_WIDTH, 28)
      }.freeze
      BASE_CARD_DIST = 230.0 # from end of name to next end of name = from top left point to next top left point
      BASE_VERTICAL_CARD_DIST = 434.0 # from top left point to next top left point

      delegate :x, :y, :width, :height, :inside?, to: :bounding_box

      attr_reader :word

      def self.guess_dist(first_name_line, second_name_line)
        all_name_boxes = first_name_line + second_name_line
        lower_bound_of_dist = all_name_boxes.max_by(&:width).width
        # figure out a way to deal with word missing
        # [first_name_line, second_name_line]
        #   .map { |line| line.minimum_dist_between_word(lower_bound_of_dist) }.min
        dists_between_words = (first_name_line + second_name_line).dists_between_words(lower_bound_of_dist)
        lower_bound_of_dist = dists_between_words.min
        Utils.average(dists_between_words.select do |dist|
                        dist < lower_bound_of_dist * Constants::UPPER_BOUND_CARD_DIST_RATIO
                      end)
      end

      def self.guest_most_accurate_name_bounding_box(name_bounding_boxes)
        name_bounding_boxes.select do |box|
          box.average_confidence > 90
        end.min_by(&:height)
      end

      def self.guess_all_boxes(ref_box, image)
        same_line_boxes = guess_all_boxes_in_line(ref_box, image)
        other_line_ref_box = [
          ref_box.next_vertical_card_bounding_box(direction: :up),
          ref_box.next_vertical_card_bounding_box(direction: :down)
        ].find { |b| b.inside?(image) }
        other_line_boxes = guess_all_boxes_in_line(other_line_ref_box, image)
        same_line_boxes + other_line_boxes
      end

      def self.guess_all_boxes_in_line(ref_box, image)
        result = [ref_box]
        cur_box = ref_box
        while (cur_box = cur_box.next_card_bounding_box(:right)) && cur_box.inside?(image)
          result.push(cur_box)
        end
        cur_box = ref_box
        while (cur_box = cur_box.next_card_bounding_box(:left)) && cur_box.inside?(image)
          result.unshift(cur_box)
        end
        result
      end

      def initialize(card_dist, name_bounding_box: nil, bounding_box: nil)
        @card_dist = card_dist
        @real_name_bounding_box = name_bounding_box
        @word = name_bounding_box&.word
        @bounding_box = bounding_box
      end

      COMPONENTS.each do |component|
        define_method "#{component}_bounding_box" do
          components_to_real_bounding_boxes[component]
        end
      end

      def next_card_bounding_box(direction = :right)
        self.class.new(
          card_dist,
          bounding_box: bounding_box.translate(x: direction == :right ? card_dist : -card_dist)
        )
      end

      def next_vertical_card_bounding_box(direction: :down)
        self.class.new(
          card_dist,
          bounding_box: bounding_box.translate(y: direction == :up ? -vertical_card_dist : vertical_card_dist)
        )
      end

      def bounding_box
        @bounding_box ||= BoundingBox.new(
          real_name_bounding_box.x_end - start_x_to_end_x_of_name,
          real_name_bounding_box.y - start_y_to_start_y_of_name,
          real_measurement(BASE_WIDTH),
          real_measurement(BASE_HEIGHT)
        )
      end

      private

      attr_reader :real_name_bounding_box, :card_dist

      def vertical_card_dist
        real_measurement(BASE_VERTICAL_CARD_DIST)
      end

      def start_x_to_end_x_of_name
        real_measurement(BASE_DIST_FROM_START_X_TO_END_X_OF_NAME)
      end

      def start_y_to_start_y_of_name
        real_measurement(BASE_DIST_FROM_START_Y_TO_START_Y_OF_NAME)
      end

      def components_to_real_bounding_boxes
        @components_to_real_bounding_boxes ||=
          COMPONENTS_TO_BASE_BOUNDING_BOXES.transform_values do |base_bounding_box|
            real_bounding_box(base_bounding_box).translate(x:, y:)
          end
      end

      def real_bounding_box(bounding_box)
        BoundingBox.new(
          *bounding_box.to_arr.map { |v| real_measurement(v) }
        )
      end

      def real_measurement(base_measurement)
        base_measurement * real_to_base_ratio
      end

      def real_to_base_ratio
        card_dist / BASE_CARD_DIST
      end
    end
  end
end