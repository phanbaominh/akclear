# frozen_string_literal: true

# rubocop:disable Metrics/CyclomaticComplexity, Metrics/ClassLength, Metrics/PerceivedComplexity
module Clears
  class BuildAttrsFromImage < ApplicationService
    include Magick
    TMP_FILE_PATH = Rails.root.join('tmp/tmp.png')
    ELITE_0_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite0_reference.png')
    ELITE_1_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite1_reference.png')
    SKILL_IMAGE_PATH = Rails.root.join('app/javascript/images/skills/')

    attr_reader :data

    def initialize(image_path)
      @image_path = image_path
    end

    def call
      image = ImageList.new(image_path)

      puts 'Processing image for extraction...'
      processed_image = ImageList.new('english.jpg') # process_image(image)
      puts 'Extracting image...'
      @data = extract(image, processed_image)

      self
    end

    private

    attr_reader :image_path, :tmp_images

    def operator_names
      @operator_names ||= Operator.all.i18n.pluck(:name).uniq.map { |n| n.gsub(/\s/, '') }
    end

    def get_value_x(current, box, dir)
      [[box[:"#{dir}_start"], current[0]].min, [box[:"#{dir}_end"], current[1]].max]
    end

    def get_value_y(current, box, dir, lang:)
      [[box[:"#{dir}_start"], current[0]].send(lang == 'jpn' ? :max : :min), [box[:"#{dir}_end"], current[1]].max]
    end

    def replace_pixels(image, x, y, columns, rows, pixel)
      pixels = image.get_pixels(x, y, columns, rows).map { pixel }
      image.store_pixels(x, y, columns, rows, pixels)
    end

    def combine_boxes_based_on_detected_string(found_strings, boxes)
      combined_boxes = []
      i = 0
      comb = nil
      found_strings_index = 0
      while i < boxes.size
        current_string = found_strings[found_strings_index]
        box = boxes[i]
        current_word = ((comb ? comb[:word] : '') + box[:word]).gsub(/\s/, '')
        matched_string = Regexp.new("^#{Regexp.escape(CGI.unescapeHTML(current_word))}").match?(current_string)
        if matched_string
          comb = if comb
                   {
                     word: [comb[:word], box[:word]].join(''),
                     x_start: [comb[:x_start], box[:x_start]].min,
                     x_end: [comb[:x_end], box[:x_end]].max,
                     y_start: [comb[:y_start], box[:y_start]].min,
                     y_end: [comb[:y_end], box[:y_end]].max
                   }
                 else
                   box
                 end
          if CGI.unescapeHTML(current_word) == current_string || (!operator_names.include?(current_string) && operator_names.include?(current_word))
            found_strings_index += 1
            combined_boxes << comb
            comb = nil
          end
        else
          combined_boxes << (comb || box)
          comb = nil
        end
        i += 1
      end
      combined_boxes
    end

    def process_image(image, lang: 'eng', h_diff: 1.4)
      white_pixel = Pixel.from_color('white')
      black_and_white_img = image
                            .quantize(2, GRAYColorspace)
                            .negate_channel(false, RedChannel, GreenChannel, BlueChannel)
                            .color_floodfill(image.columns / 2, image.rows / 2, white_pixel)
                            .tap { |i| i.alpha(OffAlphaChannel) }

      black_and_white_img.write(TMP_FILE_PATH)
      ocr_result = RTesseract.new(TMP_FILE_PATH.to_s, psm: '11', lang:)
      @found_strings = ocr_result.to_s.split("\n").reject(&:empty?).map { |s| s.gsub(/\s/, '') }
      @base_boxes = ocr_result.to_box
      boxes = combine_boxes_based_on_detected_string(
        @found_strings,
        @base_boxes
      )
      img_width = image.columns
      img_height = image.rows
      first_line_y = second_line_y = [lang == 'jpn' ? 0 : Float::INFINITY, 0]
      first_line_x = second_line_x = [img_width, 0]

      @boxes = boxes

      approx_height = boxes.select do |box|
                        operator_names.include?(box[:word])
                      end.map { |box| box[:y_end] - box[:y_start] }.min
      boxes.each do |box|
        next unless operator_names.include?(box[:word])

        height = box[:y_end] - box[:y_start]
        if box[:y_start] > first_line_y[1] * 1.2 && first_line_y[1] != 0
          second_line_y = get_value_y(second_line_y, box, :y, lang:) if height < approx_height * h_diff
          second_line_x = get_value_x(second_line_x, box, :x)
        else
          first_line_y = get_value_y(first_line_y, box, :y, lang:) if height < approx_height * h_diff
          first_line_x = get_value_x(first_line_x, box, :x)
        end
      end
      x_bound = [[first_line_x[0], second_line_x[0]].min, [first_line_x[1], second_line_x[1]].max]

      black_and_white_img
        .tap { |i| replace_pixels(i, 0, 0, img_width, first_line_y[0] - 1, white_pixel) }
        .tap do |i|
        replace_pixels(i, 0, first_line_y[1] + 1, img_width, second_line_y[0] - first_line_y[1] - 1,
                       white_pixel)
      end
        .tap do |i|
        replace_pixels(i, 0, second_line_y[1] + 1, img_width, img_height - second_line_y[1] - 1,
                       white_pixel)
      end
        .tap do |i|
        replace_pixels(i, 0, first_line_y[0], x_bound[0] - 1, second_line_y[1] - first_line_y[0],
                       white_pixel)
      end
        .tap do |i|
        replace_pixels(i, x_bound[1] + 1, first_line_y[0], img_width - x_bound[1] - 1,
                       second_line_y[1] - first_line_y[0], white_pixel)
      end
        .reduce_noise(0).unsharp_mask(6.8, 1, 2.69, 0)
    end

    def process_boxes(boxes)
      example_card = boxes.find { |box| operator_names.include?(box[:word]) }
      approx_height = example_card[:y_end] - example_card[:y_start]
      approx_distance_between_cards = approx_height * (230.0 / 24)
      boxes = boxes
              .sort { |a, b| (a[:y_start] * 5) + a[:x_start] <=> (b[:y_start] * 5) + b[:x_start] }
      combined_boxes = []
      i = 1
      comb = boxes[0]
      while i < boxes.size
        box = boxes[i]
        dist = box[:x_end] - comb[:x_end]
        new_line = box[:y_start] * 1.0 / comb[:y_start] > 1.2
        less_than_approx_distance = dist < approx_distance_between_cards * 0.4
        if new_line || !less_than_approx_distance
          comb[:word].gsub!(/[^\w\d\sぁ-ゔァ-ヴー]|_/, '')
          comb[:word].strip!
          comb[:word].squish!
          combined_boxes << comb
          comb = box
        else
          comb = {
            word: [comb[:word], box[:word]].join(' '),
            x_start: [comb[:x_start], box[:x_start]].min,
            x_end: [comb[:x_end], box[:x_end]].max,
            y_start: [comb[:y_start], box[:y_start]].min,
            y_end: [comb[:y_end], box[:y_end]].max
          }
        end
        i += 1
      end
      combined_boxes
    end

    def extract(image, processed_image, lang: 'eng', x_diff: 0.2)
      processed_image.write(TMP_FILE_PATH)
      ocr_result = RTesseract.new(TMP_FILE_PATH.to_s, psm: '11', lang:)
      @found_strings = ocr_result.to_s.split("\n").reject(&:empty?).map { |s| s.gsub(/\s/, '') }
      @base_boxes = ocr_result.to_box
      boxes = combine_boxes_based_on_detected_string(
        @found_strings,
        @base_boxes
      ).sort { |a, b| (a[:y_start] * 5) + a[:x_start] <=> (b[:y_start] * 5) + b[:x_start] }
      @boxes = boxes
      approx_height = boxes.map do |box|
        operator_names.include?(box[:word]) ?  box[:y_end] - box[:y_start] : nil
      end.compact.reduce(:+) / boxes.select { |box| operator_names.include?(box[:word]) }.size
      approx_distance_between_cards = approx_height * (230.0 / 24)

      prev = nil
      total = 0
      c = 0
      p ['approx:', approx_height, approx_distance_between_cards]
      boxes.each do |box|
        if prev &&
           box[:y_start] * 1.0 / prev[:y_start] <= 1.2 &&
           (dist_between = box[:x_end] - prev[:x_end]) &&
           (dist_between < approx_distance_between_cards * (1 + x_diff) && dist_between > approx_distance_between_cards * (1 - x_diff)) &&
           total += dist_between
          c += 1
        end
        prev = box
      end
      dist = total * 1.0 / c
      orig = x_distance_between_card = 230
      card_height = (409.0 / orig) * dist
      card_width = (185.0 / orig) * dist
      left_border_to_end_of_name = (180.0 / orig) * dist
      top_border_to_end_of_name = (375.0 / orig) * dist
      skill = [125.0, 315.0, 53.0, 53.0]
      level = [9.0, 320.0, 52.0, 42.0] # [11.0, 328.0, 50.0, 34.0]
      elite = [0, 239.0, 75.0, 62.0]

      boxes.filter_map do |box|
        card_x = box[:x_end] - left_border_to_end_of_name
        card_y = box[:y_start] - top_border_to_end_of_name

        image.crop(card_x, card_y, card_width, card_height)

        crop_image = proc do |(x, y, w, h)|
          x = x / orig * dist
          y = y / orig * dist
          w = w / orig * dist
          h = h / orig * dist
          image.crop(card_x + x, card_y + y, w, h)
        end

        operator = Operator.i18n.find_by(name: box[:word])
        next unless operator

        {
          operator_id: operator.id,
          name: operator.name,
          skill: operator.skill_game_ids.present? ? get_skill_from_image(crop_image.call(skill), operator) : nil,
          elite: get_elite_from_image(crop_image.call(elite)),
          level: get_level_from_image(crop_image.call(level))
        }
      end.sort_by { |o| o[:name] }
    end

    def compare_image(target_image, source_image, grayscaled: false)
      target_image = target_image.is_a?(Image) ? target_image : ImageList.new(target_image)
      source_image = source_image.is_a?(Image) ? source_image : ImageList.new(source_image)
      target_image = target_image.scale(source_image.columns, source_image.rows)
      target_image = target_image.quantize(2, GRAYColorspace) if grayscaled
      source_image = source_image.quantize(2, GRAYColorspace) if grayscaled

      target_image.difference(source_image)
    end

    def get_skill_from_image(image, operator)
      operator.skill_game_ids.map.with_index do |game_id, index|
        reference_skill_image = SKILL_IMAGE_PATH.join("#{game_id}.jpg")
        [compare_image(image, reference_skill_image)[0], index + 1]
      end.min_by { |a| a[0] }[1]
    end

    def get_level_from_image(image)
      image.write(TMP_FILE_PATH)
      RTesseract.new(TMP_FILE_PATH.to_s, config_file: :digits, psm: '7').to_s.to_i
    end

    def get_elite_from_image(image)
      if compare_image(image, ELITE_0_REFERENCE_IMAGE_PATH,
                       grayscaled: true)[0] < compare_image(image, ELITE_1_REFERENCE_IMAGE_PATH, grayscaled: true)[0]
        0
      else
        color_histogram = image.quantize(2, GRAYColorspace).color_histogram.transform_keys(&:to_color)
        color_histogram['white'] > color_histogram['black'] ? 2 : 1
      end
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity, Metrics/ClassLength, Metrics/PerceivedComplexity
