class ClearImage
  module Extractable
    def extract
      p 'Processing image for extraction...'

      processed_image = Extracting::Processor.make_names_white_on_black(image).write(tmp_file_path)

      extract_name_lines

      Extracting::Processor
        .paint_white_over_non_names(processed_image, *name_lines_bounding_boxes)
        .write(tmp_file_path)

      p 'Extracting image...'

      extract_name_lines

      extract_operators_data_from_all_possible_operator_cards_bounding_boxes

      combine_extracted_operators_data
    end

    private

    attr_reader :name_lines, :operators_data_from_all_possible_operator_cards_bounding_boxes

    def extract_operators_data_from_all_possible_operator_cards_bounding_boxes
      @operators_data_from_all_possible_operator_cards_bounding_boxes =
        name_lines.each_with_object([]) do |line, result|
          # line = line.filter_out_noises(distance_between_operator_card, image.columns)
          line.each do |name_box|
            ref_card_box = Extracting::OperatorCardBoundingBox.new(distance_between_operator_card,
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
      @reader ||= Extracting::Reader.new(image)
    end

    def distance_between_operator_card
      Extracting::OperatorCardBoundingBox.guess_dist(*name_lines)
    end

    def name_lines_bounding_boxes
      name_lines.map(&:merge)
    end

    def extract_name_lines
      @name_lines = extract_word_lines
                    .sort_by { |line| line.merge.word.length }
                    .last(2)
                    .sort_by { |line| line.merge.y }
    end

    def extract_word_lines
      Extracting::WordProcessor.group_words_into_lines(extract_words)
    end

    def extract_words
      ocr_word_boxes = reader.read_sparse_names(tmp_file_path)
      word_bounding_boxes = ocr_word_boxes.map { |box| Extracting::WordBoundingBox.new(box) }
      Extracting::WordProcessor.group_near_words_in_same_line(word_bounding_boxes)
    end

    def tmp_file_path
      @tmp_file_path = 'extract_result.png' # Utils.generate_tmp_path(prefix: 'clear_image_extracting', suffix: '.png')
    end
  end
end
