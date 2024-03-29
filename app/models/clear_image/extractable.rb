# frozen_string_literal: true

class ClearImage
  module Extractable # rubocop:disable Metrics/ModuleLength
    delegate :language, to: :reader

    attr_reader :benchmark_result

    def extract
      create_tmp_file
      logger.start(image_filename)
      p 'Processing image for extraction...'

      processed_image = benchmark('white_on_black') do
        Extracting::Processor.make_names_white_on_black(image, double_fill: true).write(tmp_file_path)
      end

      benchmark('extract_language') do
        reader.extract_language(processed_image:, possible_languages:)
      end
      @used_language = reader.language
      ap "Language: #{reader.language}"

      set_name_line_extractor(processed_image)

      name_lines = benchmark('extract_name_lines') do
        name_line_extractor.extract
      end

      logger.copy_image(processed_image, Logger::NAME_BLACK_ON_WHITE)
      logger.log_new_section('First name lines', name_lines)

      name_lines = benchmark('extract_name_lines_2') do
        name_line_extractor.extract(existing_name_lines: name_lines)
      end

      logger.log_new_section('Second name lines', name_lines)

      return [] if name_lines.blank?

      result =
        benchmark('extract_data') do
          extract_operators_data_based_on_name_lines(name_lines)
        end

      logger.log_new_section('result:', result)
      result
      # extract_operators_data_from_all_possible_operator_cards_bounding_boxes
      # combine_extracted_operators_data
    ensure
      logger.finish
      reader.language = nil
      delete_tmp_file
    end

    private

    attr_reader :operators_data_from_all_possible_operator_cards_bounding_boxes, :name_line_extractor

    def benchmark(name, &)
      return yield unless ENV['CLEAR_IMAGE_BENCHMARK']

      @benchmark_result ||= []
      result = nil
      benchmark_time = Benchmark.measure do
        result = yield
      end
      @benchmark_result << [name, benchmark_time.real]
      result
    end

    def logger
      Logger
    end

    def set_name_line_extractor(image)
      return @name_line_extractor if @name_line_extractor

      extractor_klass = "ClearImage::Extracting::#{reader.language.to_s.delete('-').capitalize}::NameLineExtractor"
      @name_line_extractor = if Object.const_defined?(extractor_klass)
                               extractor_klass.constantize.new(image)
                             else
                               Extracting::NameLineExtractor.new(image)
                             end
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
          Extracting::OperatorExtractor.new(box, image, operators, elite_0_image, elite_1_image,
                                            similarity_comparable_mapper).extract
        end
      end.flatten.compact
    end

    def operators
      return @operators if @operators

      @operators ||=
        I18n.with_locale(reader.language) do
          Operator.i18n.eager_load(:string_translations).to_a
        end
      @operators.each do |operator|
        operator.name = operator.name(locale: reader.language).gsub(/\s+/, '')

        operator.similarity_comparable_name = similarity_comparable_mapper.map(operator.name)
      end
    end

    def similarity_comparable_mapper
      @similarity_comparable_mapper ||= ClearImage::Extracting::SimilarityComparableMapper.new(operators)
    end

    def max_possible_operator_cards
      operators_data_from_all_possible_operator_cards_bounding_boxes.first.size
    end

    def reader
      Extracting::Reader
    end

    def get_distance_between_operator_card(name_lines)
      Extracting::OperatorCardBoundingBox.guess_dist(*name_lines)
    end

    def image_filename
      image.filename.split('/').last.split('.').first
    end
  end
end
