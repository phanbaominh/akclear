# frozen_string_literal: true

class ClearImage
  module Extracting
    class NameLineExtractor
      include TmpFileStorable

      def initialize(image)
        @image = image
        @extract_name_line_count = 0
      end

      def final_name_lines?
        @extract_name_line_count == 3
      end

      def extract(existing_name_lines: nil)
        @extract_name_line_count += 1

        if existing_name_lines
          extract_all_from_cropped_image(existing_name_lines)
        else
          extract_all_from_full_image
        end
      end

      private

      attr_reader :image, :extract_name_line_count

      def extract_all_from_cropped_image(name_lines)
        result = []

        name_lines.each_with_index do |line, i|
          name_line, border_thickness, chosen_image = extract_from_cropped_image(line)

          name_line.each do |box|
            box.translate!(y: line.y - 2 - border_thickness.sum, x: -border_thickness.sum)
          end
          logger.copy_image(chosen_image, "crop_image_#{i}_w#{border_thickness[0]}_b#{border_thickness[1]}.png")
          logger.log('final name_line', name_line)
          result << name_line
        end
        result
      end

      def extract_from_cropped_image(line)
        crop_img = image.crop(0, line.y - 2, image.columns, line.y_end - line.y + 2)
        [[10, 10], [15, 0]].filter_map do |(w_border, b_border)|
          bordered_crop_image = crop_img.border(
            w_border, w_border, 'white'
          ).border(
            b_border, b_border, 'black'
          )
          bordered_crop_image.write(tmp_file_path)
          word_lines = extract_word_lines(lined_up: true)
          word_line = word_lines.first

          next if word_line.blank?

          # word_line.keep_evenly_high_boxes unless @extract_name_line_count == 1
          # word_line.remove_outlier! # unless final_name_lines?
          logger.log("word line w#{w_border} b#{b_border}", word_line)

          [word_line, [w_border, b_border], bordered_crop_image]
        end.max_by { |(word_line, _, _)| word_line.map(&:word).join.length }
      end

      def extract_all_from_full_image
        all_word_lines = extract_word_lines
        all_word_lines.each(&:keep_evenly_high_boxes) unless @extract_name_line_count == 1
        all_word_lines.each(&:remove_outlier!) unless final_name_lines?
        logger.log('all_word_lines:', all_word_lines)
        all_word_lines
          .sort_by do |line|
            merged_word = line.merge.word
            merged_word = merged_word.gsub(/\w+/, 'a') if reader.zh_cn? # count a continuous latin string as one word
            merged_word.length
          end
          .last(2)
          .sort_by { |line| line.merge.y }
      end

      def extract_word_lines(lined_up: false)
        words = extract_words(lined_up:).reject do |box|
          box.word =~ /Unit/i || box.word =~ /star/i || box.word =~ /快捷编队/
        end
        logger.log('words:', words)
        word_lines = Extracting::WordProcessor
                     .group_words_into_lines(words, allowed_box_conf)
        return word_lines unless reader.zh_cn?

        word_lines.reject! do |line|
          line.reject! do |box|
            next false if box.word.include?('X')

            box.word =~ /\p{Latin}+/ && box.word =~ /\p{Han}+/
          end
          line.empty?
        end
        word_lines
      end

      def allowed_box_conf
        return Configuration.word_in_line_first_pass_confidence_threshold if @extract_name_line_count == 1

        Configuration.word_in_line_second_pass_confidence_threshold
      end

      def extract_words(lined_up: false)
        # small_squad = @name_lines && @name_lines.map(&:size).sum < 6
        ocr_word_boxes, psm = lined_up ? reader.read_lined_names(tmp_file_path) : reader.read_sparse_names(tmp_file_path)
        word_bounding_boxes = ocr_word_boxes.map { |box| Extracting::WordBoundingBox.new(box) }
        # ap word_bounding_boxes
        word_bounding_boxes.reject! { |box| box.near_end?(image) }
        word_bounding_boxes.reject! { |box| box.word.length < 3 } if reader.en?
        if reader.zh_cn?
          word_bounding_boxes.reject! do |box|
            box.word =~ /LV\d+/ || box.word =~ /M\d+/ || box.word =~ /^\d+\w{0,1}/
          end

        end
        if lined_up && reader.zh_cn?
          words = reader.read_lined_names_text(tmp_file_path, psm:)
          Extracting::WordProcessor.group_based_on_read_words(word_bounding_boxes, words)
        else
          Extracting::WordProcessor.group_near_words_in_same_line(word_bounding_boxes)
        end
      end

      def logger
        Logger
      end

      def reader
        Extracting::Reader
      end
    end
  end
end
