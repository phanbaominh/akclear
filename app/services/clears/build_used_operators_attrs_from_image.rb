# frozen_string_literal: true

# rubocop:disable Metrics/CyclomaticComplexity, Metrics/ClassLength, Metrics/PerceivedComplexity
module Clears
  class BuildUsedOperatorsAttrsFromImage < ApplicationService
    include Magick
    TMP_FILE_PATH = Rails.root.join('tmp/tmp.png')
    ELITE_0_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite0_reference.png')
    ELITE_1_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite1_reference.png')
    SKILL_IMAGE_PATH = Rails.root.join('app/javascript/images/skills/')
    NAME_SIMILARITY_THRESHOLD = 0.7
    LOCALE_TO_TESSERACT_LANG = {
      en: 'eng',
      jp: 'jpn'
    }.freeze

    attr_reader :data

    def initialize(image_path)
      @image_path = image_path
    end

    def call
      data = nil
      I18n.with_locale(image_language) do
        puts "Processing image (lang=#{image_language}) for extraction..."
        processed_image = if lang == 'eng'
                            # ImageList.new('english.jpg')
                            process_image(image)
                          else
                            process_image(image)
                          end
        processed_image.write('tmp/processed.png')
        # processed_image = ImageList.new('tmp/processed.png')
        puts 'Extracting image...'
        data = extract(image, processed_image)
        Success(data)
      end

      # FileUtils.rm TMP_FILE_PATH, force: true
    end

    private

    attr_reader :image_path, :tmp_images

    def image
      @image ||= ImageList.new(image_path)
    end

    def image_language
      greyscale_image.write(TMP_FILE_PATH)
      all_characters_regex = /[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}]+/u
      @image_language ||= LOCALE_TO_TESSERACT_LANG.max_by do |_locale, tess_lang_code|
        RTesseract.new(TMP_FILE_PATH.to_s, psm: '11', lang: tess_lang_code).to_box
                  .select { |box| box[:confidence] > 80 }
                  .pluck(:word)
                  .join
                  .gsub(all_characters_regex, '').size
      end.first
    end

    def lang
      LOCALE_TO_TESSERACT_LANG[I18n.locale]
    end

    def processed_operator_names
      @processed_operator_names ||= operator_names.map { |n| n.gsub(/\s/, '') } - ['W']
    end

    def operator_names
      @operator_names = Operator.all.i18n.pluck(:name).uniq
    end

    def get_value_x(current, box, dir)
      [[box[:"#{dir}_start"], current[0]].min, [box[:"#{dir}_end"], current[1]].max]
    end

    def get_value_y(current, box, dir)
      [[box[:"#{dir}_start"], current[0]].send(lang == 'jpn' ? :max : :min), [box[:"#{dir}_end"], current[1]].max]
    end

    def replace_pixels(image, x, y, columns, rows, pixel)
      pixels = image.get_pixels(x, y, columns, rows).map { pixel }
      image.store_pixels(x, y, columns, rows, pixels)
    end

    def reduce_box(comb)
      di = 0
      comb[:idx] = comb[:word].size.times.map { |i| comb[:start_idx] + i } if comb[:start_idx]
      comb_dup = comb.deep_dup
      while di < comb[:word].size
        reduced_word = (comb[:word][0...di] + comb[:word][(di + 1)..]).join
        word = comb[:word].join
        if (m1 = get_largest_similar_ratio(reduced_word)) >= (m2 = get_largest_similar_ratio(word))
          comb.each_value { |v| v.try(:delete_at, di) }
        else
          di += 1
        end
        m = [m1, m2].max
      end
      di = comb_dup[:word].size - 1
      while di >= 0
        reduced_word = (comb_dup[:word][0...di] + comb_dup[:word][(di + 1)..]).join
        word = comb_dup[:word].join
        if (m1 = get_largest_similar_ratio(reduced_word)) >= (m2 = get_largest_similar_ratio(word))
          comb_dup.each_value { |v| v.try(:delete_at, di) }
          di = [di, comb_dup[:word].size - 1].min
        else
          di -= 1
        end
        mdup = [m1, m2].max
      end
      # p "RESULT: #{[comb[:word].join, comb_dup[:word].join, m, mdup].inspect}"
      comb = comb_dup if mdup > m
      get_final_box(comb)
    end

    def get_final_box(comb)
      comb[:word] = comb[:word].join
      comb[:x_start] = comb[:x_start].min
      comb[:x_end] = comb[:x_end].max
      comb[:y_start] = comb[:y_start].min
      comb[:y_end] = comb[:y_end].max
      comb
    end

    def sort_boxes(boxes)
      boxes
      # boxes.sort { |a, b| (a[:y_start] * 5) + a[:x_start] <=> (b[:y_start] * 5) + b[:x_start] }
    end

    def get_box_confidence(box)
      box[:confidence].is_a?(Array) ? box[:confidence].sum / box[:confidence].size : box[:confidence]
    end

    def combine_boxes_based_on_detected_string_jpn(_found_strings, boxes)
      combined_boxes = []
      i = 0
      comb = {}
      reduce_len = 0
      start_reduce = false
      last_ratio = 0
      while i < boxes.size
        box = boxes[i]
        box.each do |k, v|
          comb[k] ||= []
          comb[k] << v
        end
        comb[:start_idx] ||= i
        current_word = CGI.unescapeHTML((comb[:word].present? ? comb[:word].join('') : box[:word]).gsub(/\s/, ''))
        ratio = get_largest_similar_ratio(current_word)

        # p [current_word, ratio, last_ratio, reduce_len, start_reduce]
        dist = nil
        new_dist = nil
        if comb[:x_start].present? && comb[:x_start].size > 2
          dist = comb[:x_start][1] - comb[:x_end][0]
          new_dist = comb[:x_start][-1] - comb[:x_end][-2]
        end
        # p "DIST #{dist} #{new_dist} #{comb.inspect}"

        if ratio == 1 || (dist && dist < 0)
          combined_boxes << get_final_box(comb)
          comb = {}
          reduce_len = 0
          start_reduce = false
          last_ratio = 0
          i += 1
        elsif dist && (new_dist > dist * 2 || new_dist * 2 < dist)
          comb1 = {}

          comb.each do |k, v|
            comb1[k] = new_dist > dist * 2 ? v[0...-1] : v[0...-2]
          end
          comb1[:start_idx] = comb[:start_idx]
          comb1 = reduce_box(comb1)
          combined_boxes << comb1
          i = (comb1[:idx].max || comb1[:start_idx]) + 1
          comb = {}
          reduce_len = 0
          start_reduce = false
          last_ratio = 0
        elsif last_ratio > ratio && reduce_len > 1
          comb = reduce_box(comb)

          combined_boxes << comb
          i = comb[:idx].max + 1
          comb = {}
          reduce_len = 0
          start_reduce = false
          last_ratio = 0
        else
          if ratio > last_ratio
            start_reduce = true
          elsif start_reduce
            reduce_len += 1
          end

          i += 1
          last_ratio = ratio
        end
      end
      combined_boxes
    end

    def combine_boxes_based_on_detected_string_eng(found_strings, boxes)
      combined_boxes = []
      i = 0
      comb = nil
      found_strings_index = 0
      while i < boxes.size
        current_string = found_strings[found_strings_index]
        box = boxes[i]
        current_word = ((comb ? comb[:word].join : '') + box[:word]).gsub(/\s/, '')
        matched_string = Regexp.new("^#{Regexp.escape(CGI.unescapeHTML(current_word))}").match?(current_string)
        if matched_string
          comb = {}
          box.each do |k, v|
            comb[k] ||= []
            comb[k] << v
          end
          # comb = if comb
          #          {
          #            word: [comb[:word], box[:word]].join(''),
          #            x_start: [comb[:x_start], box[:x_start]].min,
          #            x_end: [comb[:x_end], box[:x_end]].max,
          #            y_start: [comb[:y_start], box[:y_start]].min,
          #            y_end: [comb[:y_end], box[:y_end]].max,
          #            confidence: [comb[:confidence], box[:confidence]].flatten
          #          }
          #        else
          #          box
          #        end
          if CGI.unescapeHTML(current_word) == current_string || (!operator_names.include?(current_string) && operator_names.include?(current_word))
            found_strings_index += 1
            combined_boxes << get_final_box(comb)
            comb = nil
          end
        else
          combined_boxes << (comb ? get_final_box(comb) : box)
          comb = nil
        end
        i += 1
      end
      combined_boxes
    end

    def combine_boxes_based_on_detected_string(found_strings, boxes)
      boxes = sort_boxes(boxes)
      if lang == 'jpn'
        combine_boxes_based_on_detected_string_jpn(found_strings,
                                                   boxes)
      else
        combine_boxes_based_on_detected_string_eng(
          found_strings, boxes
        )
      end.select { |box| box[:word].present? }
    end

    def greyscale_image
      white_pixel = Pixel.from_color('white')
      @greyscale_image ||= image
                           .quantize(2, GRAYColorspace)
                           .negate_channel(false, RedChannel, GreenChannel, BlueChannel)
                           .color_floodfill(image.columns / 2, image.rows / 2, white_pixel)
                           .tap { |i| i.alpha(OffAlphaChannel) }
    end

    def process_image(image, h_diff: 1.4)
      black_and_white_img = greyscale_image

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

      boxes_with_operator = boxes.select { |box| processed_operator_names.include?(box[:word]) }

      approx_height = boxes_with_operator.map { |box| box[:y_end] - box[:y_start] }.min
      approx_line_y_start_diff = (422.0 / 24) * approx_height
      approx_line_y_end_diff = (464.0 / 24) * approx_height
      ys = []
      boxes_with_operator.each do |box|
        height = box[:y_end] - box[:y_start]
        if box[:y_start] > first_line_y[1] * 1.2 && first_line_y[1] != 0
          ys << [box[:y_start], box[:y_end]]
          second_line_y = get_value_y(second_line_y, box, :y) if height < approx_height * h_diff
          second_line_x = get_value_x(second_line_x, box, :x)
        else
          first_line_y = get_value_y(first_line_y, box, :y) if height < approx_height * h_diff
          first_line_x = get_value_x(first_line_x, box, :x)
        end
      end
      # binding.pry
      x_bound = [[first_line_x[0], second_line_x[0]].min, [first_line_x[1], second_line_x[1]].max]

      if second_line_y[1] == 0
        if first_line_y[1] + approx_line_y_end_diff > img_height
          second_line_y = first_line_y
          first_line_y = [second_line_y[0] - approx_line_y_start_diff, second_line_y[0] - approx_line_y_end_diff]
        else
          second_line_y = [ys.map(&:first).min, ys.map(&:second).min]
        end
      end

      @first_line_y_start = first_line_y[0]
      @second_line_y_start = second_line_y[0]
      white_pixel = Pixel.from_color('white')

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
        #   .tap do |i|
        #   replace_pixels(i, 0, first_line_y[0], x_bound[0] - 1, second_line_y[1] - first_line_y[0],
        #                  white_pixel)
        # end
        #   .tap do |i|
        #   replace_pixels(i, x_bound[1] + 1, first_line_y[0], img_width - x_bound[1] - 1,
        #                  second_line_y[1] - first_line_y[0], white_pixel)
        # end
        .reduce_noise(0).unsharp_mask(6.8, 1, 2.69, 0)
    end

    def process_boxes(boxes)
      example_card = boxes.find { |box| processed_operator_names.include?(box[:word]) }
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

    def guess_boxes(boxes, ref_box, card_width, image_width, x_error, dist)
      last_boxes = []
      sp = ref_box[:x_end]
      while sp - dist > card_width
        sp -= dist
        last_boxes.unshift(if (box = boxes.find { |box| box[:x_end] < sp + x_error && box[:x_end] > sp - x_error })
                             box
                           else
                             { word: nil, x_end: sp, y_start: ref_box[:y_start] }
                           end)
      end
      last_boxes.push(ref_box)
      sp = ref_box[:x_end]

      while sp + dist < image_width
        sp += dist
        last_boxes << if (box = boxes.find { |box| box[:x_end] < sp + x_error && box[:x_end] > sp - x_error })
                        box
                      else
                        { word: nil, x_end: sp, y_start: ref_box[:y_start] }
                      end
      end
      last_boxes
    end

    def extract(image, processed_image, x_diff: 0.2)
      processed_image.write(TMP_FILE_PATH)
      ocr_result = RTesseract.new(TMP_FILE_PATH.to_s, psm: '11', lang:)
      @found_strings = ocr_result.to_s.split("\n").reject(&:empty?).map { |s| s.gsub(/\s/, '') }
      @base_boxes = ocr_result.to_box
      boxes = combine_boxes_based_on_detected_string(
        @found_strings,
        @base_boxes
      ).sort { |a, b| (a[:y_start] * 5) + a[:x_start] <=> (b[:y_start] * 5) + b[:x_start] }
      @boxes = boxes
      boxes_with_operator = boxes.select { |box| processed_operator_names.include?(box[:word]) }
      boxes_with_operator_height = boxes_with_operator.map { |box| box[:y_end] - box[:y_start] }
      min_height = boxes_with_operator_height.min
      boxes_with_valid_height = boxes_with_operator_height.select { |height| height <= min_height * 1.2 }
      approx_height = if lang == 'eng'
                        boxes_with_operator_height.sum / boxes_with_operator_height.size
                      else
                        boxes_with_valid_height.sum / boxes_with_valid_height.size
                      end

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
      skill = [125.0, 315.0, 53.0, 53.0, 'skill']
      level = [7.0, 319.0, 56.0, 42.0, 'level'] # [11.0, 328.0, 50.0, 34.0]
      elite = [0, 239.0, 75.0, 62.0, 'elite']

      @first_line_y_start ||= 494
      p @first_line_y_start
      start_of_second_line_idx = boxes.find_index do |box|
        box[:y_start] > @first_line_y_start * 1.5
      end
      first_line_boxes = boxes[0...start_of_second_line_idx]
      second_line_boxes = boxes[start_of_second_line_idx..]
      max_conf_first_line_box = first_line_boxes.select do |box|
                                  processed_operator_names.include?(box[:word])
                                end.max_by do |box|
        box[:confidence].is_a?(Array) ? box[:confidence].sum / box[:confidence].size : box[:confidence]
      end
      max_conf_second_line_box = second_line_boxes.select do |box|
                                   processed_operator_names.include?(box[:word])
                                 end.max_by do |box|
        box[:confidence].is_a?(Array) ? box[:confidence].sum / box[:confidence].size : box[:confidence]
      end
      boxes = guess_boxes(first_line_boxes, max_conf_first_line_box, card_width, image.columns, approx_height, dist) +
              guess_boxes(second_line_boxes, max_conf_second_line_box, card_width, image.columns, approx_height, dist)

      white_pixel = Pixel.from_color('white')
      i = -1
      boxes.filter_map do |box|
        card_x = box[:x_end] - left_border_to_end_of_name
        card_y = box[:y_start] - top_border_to_end_of_name

        if box[:word].nil? || find_most_matched_name(box[:word]).nil?
          dif = approx_height * 1.0 / 7
          image.crop(card_x, box[:y_start] - dif, card_width * 1.2, approx_height + dif)
               .quantize(2, GRAYColorspace).negate_channel(false, RedChannel, GreenChannel, BlueChannel)
               .color_floodfill(card_width * 1.2 / 2, 0, white_pixel).write(TMP_FILE_PATH)
          ocr_result = RTesseract.new(TMP_FILE_PATH.to_s, psm: '11', lang:)

          comb = ocr_result.to_box.each_with_object({}) do |b, memo|
            b.each do |k, v|
              memo[k] ||= []
              memo[k] << v
            end
          end
          if comb[:word].present?
            reduced_box = reduce_box(comb)
            box[:word] = reduced_box[:word]
            if comb[:x_end].present?
              box[:x_end] = card_x + reduced_box[:x_end]
              card_x = box[:x_end] - left_border_to_end_of_name
            end
          end

        end
        operator = find_operator(box[:word])
        next unless operator

        i += 1

        image.crop(card_x, card_y, card_width, card_height).write("tmp/#{i}.png")
        crop_image = proc do |(x, y, w, h, type)|
          x = x / orig * dist
          y = y / orig * dist
          w = w / orig * dist
          h = h / orig * dist
          image.crop(card_x + x, card_y + y, w, h).write("tmp/#{i}_#{type}.png")
        end
        {
          operator_id: operator.id,
          skill: operator.skill_game_ids.present? ? get_skill_from_image(crop_image.call(skill), operator) : nil,
          elite: get_elite_from_image(crop_image.call(elite), operator),
          level: get_level_from_image(crop_image.call(level), operator)
          # word: box[:word]
        }
      end.sort_by { |o| o[:name] }
    end

    def similar_ratio(a, b)
      a.levenshtein_similar(b)
    end

    def find_most_matched_name(detected_name)
      most_matched_name = operator_names.min_by do |name|
        Amatch::Levenshtein.new(name).match(detected_name)
      end

      return most_matched_name if most_matched_name.levenshtein_similar(detected_name) > NAME_SIMILARITY_THRESHOLD
    end

    def get_largest_similar_ratio(string)
      operator_names.map do |name|
        name.levenshtein_similar(string)
      end.max
    end

    def find_operator(detected_name)
      return unless detected_name && (most_matched_name = find_most_matched_name(detected_name))

      Operator.i18n.find_by(name: most_matched_name)
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

    def get_level_from_image(image, _operator)
      image.write(TMP_FILE_PATH)
      RTesseract.new(TMP_FILE_PATH.to_s, config_file: :digits, psm: '7').to_s.to_i
    end

    def get_elite_from_image(image, operator)
      detected_elite = if compare_image(image, ELITE_0_REFERENCE_IMAGE_PATH,
                                        grayscaled: true)[0] < compare_image(image, ELITE_1_REFERENCE_IMAGE_PATH,
                                                                             grayscaled: true)[0]
                         0
                       else
                         color_histogram = image.quantize(2, GRAYColorspace).color_histogram.transform_keys(&:to_color)
                         color_histogram['white'] * 1.1 > color_histogram['black'] ? 2 : 1
                       end
      [detected_elite, operator.max_elite].min
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity, Metrics/ClassLength, Metrics/PerceivedComplexity
