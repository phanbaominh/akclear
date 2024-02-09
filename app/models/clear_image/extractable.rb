class ClearImage
  module Extractable
    ELITE_0_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite0_reference.png')
    ELITE_1_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite1_reference.png')
    delegate :language, to: :reader

    def extract
      create_tmp_file
      logger.start(image_filename)
      p 'Processing image for extraction...'

      processed_image = Extracting::Processor.make_names_white_on_black(image).write(tmp_file_path)
      reader.extract_language(processed_image:)

      extract_name_lines

      logger.copy_image(processed_image, Logger::NAME_BLACK_ON_WHITE)
      logger.log('First name lines', name_lines)
      # processed_image = Extracting::Processor.paint_white_in_between_names(processed_image, *name_lines)

      # processed_image_2 = Extracting::Processor
      #                     .paint_white_over_non_names(processed_image, *name_lines).write(tmp_file_path)
      # logger.copy_image(processed_image_2, Logger::WHITE_OVER_NON_NAMES_1)

      # @lined = true

      # extract_name_lines
      # logger.log('Second name lines', name_lines)

      # return [] if name_lines.size != 2

      # boundary_lines = Extracting::Processor.get_name_boundary_lines(image, *name_lines)
      # processed_image = Extracting::Processor
      #                   .paint_white_over_non_names(processed_image, *name_lines).write(tmp_file_path)
      # logger.copy_image(processed_image, Logger::WHITE_OVER_NON_NAMES_2)

      # extract_name_lines(boundary_lines)

      @lined = true
      boundary_lines = Extracting::Processor.get_name_boundary_lines(image, *name_lines)
      extract_name_line_v2(processed_image, boundary_lines)

      logger.log('Third name lines', name_lines)

      result = extract_operators_data_based_on_name_lines

      logger.log('result:', result)
      result

      # extract_operators_data_from_all_possible_operator_cards_bounding_boxes

      # combine_extracted_operators_data
    ensure
      logger.finish
      delete_tmp_file
    end

    private

    attr_reader :name_lines, :operators_data_from_all_possible_operator_cards_bounding_boxes

    def logger
      @logger ||= Logger
    end

    def extract_operators_data_based_on_name_lines
      distance_between_operator_card = get_distance_between_operator_card
      logger.log('final distance_between_operator_card:', distance_between_operator_card)
      first = true
      name_lines.map do |line|
        line.map do |name_box|
          box = Extracting::OperatorCardBoundingBox.new(distance_between_operator_card,
                                                        name_bounding_box: name_box)

          if first
            elite_bb = box.elite_bounding_box
            first = false
            @elite_0_image = elite_0_image.scale(elite_bb.width, elite_bb.height)
            @elite_1_image = elite_1_image.scale(elite_bb.width, elite_bb.height)
          end
          Extracting::OperatorExtractor.new(box, image, reader, operators, elite_0_image, elite_1_image).extract
        end
      end.flatten.compact
    end

    def operators
      @operators ||=
        I18n.with_locale(reader.language) do
          Operator.i18n.pluck(:id, :name).map { |id, name| [id, name.gsub(/\s+/, '')] }
        end
    end

    def elite_1_image
      @elite_1_image ||= Magick::ImageList.new(ELITE_1_REFERENCE_IMAGE_PATH).first
    end

    def elite_0_image
      @elite_0_image ||= Magick::ImageList.new(ELITE_0_REFERENCE_IMAGE_PATH).first
    end

    def extract_operators_data_from_all_possible_operator_cards_bounding_boxes
      @operators_data_from_all_possible_operator_cards_bounding_boxes =
        name_lines.each_with_object([]) do |line, result|
          line.each do |name_box|
            ref_card_box = Extracting::OperatorCardBoundingBox.new(get_distance_between_operator_card,
                                                                   name_bounding_box: name_box)
            operators_data_based_on_ref_box =
              Extracting::OperatorCardBoundingBox.guess_all_boxes(ref_card_box, image).map do |box|
                Extracting::OperatorExtractor.new(box, image, reader).extract
              end
            result << operators_data_based_on_ref_box
          end
        end
    end

    def max_possible_operator_cards
      operators_data_from_all_possible_operator_cards_bounding_boxes.first.size
    end

    def combine_extracted_operators_data
      Array.new(max_possible_operator_cards) do |i|
        all_ith_operator_card_data = operators_data_from_all_possible_operator_cards_bounding_boxes
                                     .map { |possible_data| possible_data[i] }.compact
        next if all_ith_operator_card_data.empty?

        result = {}
        %i[operator skill level elite].each do |attr|
          most_common_attr_value = all_ith_operator_card_data.pluck(attr).tally.first.first
          result[attr] = most_common_attr_value
        end
        result
      end.compact
    end

    def reader
      Extracting::Reader
    end

    def get_distance_between_operator_card
      Extracting::OperatorCardBoundingBox.guess_dist(*name_lines, image)
    end

    def name_lines_bounding_boxes
      name_lines.map(&:merge)
    end

    def final_name_lines?
      @extract_name_line_count == 3
    end

    def extract_name_line_v2(processed_image, boundary_lines)
      @extract_name_line_count ||= 0
      @extract_name_line_count += 1
      @name_lines = []

      boundary_lines.each_with_index do |line, i|
        cur = nil
        translated = [15]
        chosen_image = nil
        [[10, 5], [5, 10], [10, 10], [15, 0]].each do |(w_border, b_border)|
          crop_img = processed_image.crop(0, line[0] - 2, processed_image.columns, line[1] - line[0] + 2).border(
            w_border, w_border, 'white'
          ).border(
            b_border, b_border, 'black'
          )
          crop_img.write(tmp_file_path)
          word_lines = extract_word_lines
          word_line = word_lines.first

          next if word_line.blank?

          # word_line.keep_evenly_high_boxes unless @extract_name_line_count == 1
          # word_line.remove_outlier! # unless final_name_lines?
          logger.log("word line w#{w_border} b#{b_border}", word_line)

          if cur && cur.map(&:word).join.length < word_line.map(&:word).join.length
            cur = word_line
            translated = [w_border, b_border]
            chosen_image = crop_img
          elsif !cur
            cur = word_line
            translated = [w_border, b_border]
            chosen_image = crop_img
          end
        end
        word_line = cur

        word_line.each do |box|
          box.translate!(y: line[0] - 2 - translated.sum, x: -translated.sum)
        end
        logger.copy_image(chosen_image, "crop_image_#{i}_w#{translated[0]}_b#{translated[1]}.png")
        logger.log('final word line', word_line)
        @name_lines << word_line
      end
      @name_lines.each_with_index do |line, i|
        line.y = line.center_y || boundary_lines[i].first
      end
    end

    def extract_name_lines(boundary_lines = nil)
      @extract_name_line_count ||= 0
      @extract_name_line_count += 1
      all_word_lines = extract_word_lines
      all_word_lines.each { |line| line.keep_evenly_high_boxes } unless @extract_name_line_count == 1
      all_word_lines.each { |line| line.remove_outlier! } unless final_name_lines?
      logger.log('all_word_lines:', all_word_lines)
      @name_lines = all_word_lines
                    .sort_by { |line| line.merge.word.length }
                    .last(2)
                    .sort_by { |line| line.merge.y }
      return unless boundary_lines

      @name_lines.each_with_index do |line, i|
        line.y = line.center_y || boundary_lines[i].first
      end
    end

    def extract_word_lines
      words = extract_words.reject { |box| box.word =~ /Unit/i }
      logger.log('words:', words)
      Extracting::WordProcessor
        .group_words_into_lines(words, allowed_box_conf)
    end

    def allowed_box_conf
      return Configuration.word_in_line_first_pass_confidence_threshold if @extract_name_line_count == 1

      Configuration.word_in_line_second_pass_confidence_threshold
    end

    def extract_words
      small_squad = @name_lines && @name_lines.map(&:size).sum < 6
      ocr_word_boxes = @lined ? reader.read_lined_names(tmp_file_path) : reader.read_sparse_names(tmp_file_path)
      word_bounding_boxes = ocr_word_boxes.map { |box| Extracting::WordBoundingBox.new(box) }
      ap ['raw words', word_bounding_boxes] if @extract_name_line_count == 3
      word_bounding_boxes.reject! { |box| box.near_end?(image) }
      word_bounding_boxes.reject! { |box| box.word.length < 3 } if language == :en
      Extracting::WordProcessor.group_near_words_in_same_line(word_bounding_boxes) # POINT
    end

    def image_filename
      image.filename.split('/').last.split('.').first
    end
  end
end
