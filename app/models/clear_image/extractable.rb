# frozen_string_literal: true

class ClearImage
  module Extractable
    delegate :language, to: :reader

    def extract
      create_tmp_file
      logger.start(image_filename)
      p 'Processing image for extraction...'

      processed_image = Extracting::Processor.make_names_white_on_black(image, double_fill: true).write(tmp_file_path)
      reader.extract_language(processed_image:)

      set_name_line_extractor(processed_image)

      name_lines = name_line_extractor.extract

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

      name_lines = name_line_extractor.extract(existing_name_lines: name_lines)

      logger.log('Third name lines', name_lines)

      result = extract_operators_data_based_on_name_lines(name_lines)

      logger.log('result:', result)
      result
      # extract_operators_data_from_all_possible_operator_cards_bounding_boxes
      # combine_extracted_operators_data
    ensure
      logger.finish
      delete_tmp_file
    end

    private

    attr_reader :operators_data_from_all_possible_operator_cards_bounding_boxes, :name_line_extractor

    def logger
      Logger
    end

    def set_name_line_extractor(image)
      @name_line_extractor = Extracting::NameLineExtractor.new(image)
    end

    def extract_operators_data_based_on_name_lines(name_lines)
      distance_between_operator_card = get_distance_between_operator_card(name_lines)
      logger.log('final distance_between_operator_card:', distance_between_operator_card)
      first = true
      elite_0_image = Extracting::OperatorExtractor.elite_0_image
      elite_1_image = Extracting::OperatorExtractor.elite_1_image
      name_lines.map do |line|
        line.all_boxes_y = line.most_common_box_y || line.y
        line.map do |name_box|
          box = Extracting::OperatorCardBoundingBox.new(distance_between_operator_card,
                                                        name_bounding_box: name_box)

          if first
            elite_bb = box.elite_bounding_box
            first = false
            elite_0_image = elite_0_image.scale(elite_bb.width, elite_bb.height)
            elite_1_image = elite_1_image.scale(elite_bb.width, elite_bb.height)
          end
          Extracting::OperatorExtractor.new(box, image, operators, elite_0_image, elite_1_image).extract
        end
      end.flatten.compact
    end

    def operators
      @operators ||=
        I18n.with_locale(reader.language) do
          Operator.i18n.pluck(:id, :name).map { |id, name| [id, name.gsub(/\s+/, '')] }
        end
    end

    def max_possible_operator_cards
      operators_data_from_all_possible_operator_cards_bounding_boxes.first.size
    end

    def reader
      Extracting::Reader
    end

    def get_distance_between_operator_card(name_lines)
      Extracting::OperatorCardBoundingBox.guess_dist(*name_lines, image)
    end

    def image_filename
      image.filename.split('/').last.split('.').first
    end
  end
end
