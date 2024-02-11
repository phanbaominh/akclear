# frozen_string_literal: true

class ClearImage
  module Extracting
    class OperatorExtractor
      include Magick
      include TmpFileStorable

      SKILL_IMAGE_PATH = Rails.root.join('app/javascript/images/skills/')
      ELITE_0_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite0_reference.png')
      ELITE_1_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite1_reference.png')
      NAME_SIMILARITY_THRESHOLD = 0.7

      class << self
        def elite_1_image
          Magick::ImageList.new(ELITE_1_REFERENCE_IMAGE_PATH).first
        end

        def elite_0_image
          Magick::ImageList.new(ELITE_0_REFERENCE_IMAGE_PATH).first
        end
      end

      def initialize(operator_card_bounding_box, image, operators, elite_0_image, elite_1_image)
        @operator_card_bounding_box = operator_card_bounding_box
        @image = image
        @operators = operators || Operator.i18n.pluck(:id, :name).map { |id, name| [id, name.gsub(/\s+/, '')] }
        @elite_0_image = elite_0_image
        @elite_1_image = elite_1_image
      end

      def extract
        I18n.with_locale(language) do
          operator =
            match_operator(box_word, similarity_threshold: 0.8) || match_operator(redetect_word_from_cropped_box_image)

          log_box(operator)
          next unless operator

          result = { operator_id: operator.id }

          return result if Configuration.operator_name_only

          %i[skill level elite].each do |component|
            result[component] =
              send(:"get_#{component}_from_image", image.crop(*operator_card_bounding_box.send("#{component}_bounding_box").to_arr),
                   operator, result)
          end
          result
        end
      end

      private

      attr_reader :operator_card_bounding_box, :image, :operators, :elite_0_image, :elite_1_image

      def reader
        ClearImage::Extracting::Reader
      end

      def match_operator(word, similarity_threshold: NAME_SIMILARITY_THRESHOLD)
        word = reader.process_name(word)

        match_name_containing(word) || match_special_name(word) || match_name_with_highest_similarity(word,
                                                                                                      similarity_threshold)
      end

      def match_special_name(word)
        if reader.jp?

          return unless word.include?('Rヤ')

          match_name_with_highest_similarity('キリンRヤトウ', 1)
        elsif reader.zh_cn?
          return unless word.include?('X夜')

          match_name_with_highest_similarity('麒麟R夜刀', 1)
        elsif reader.en?
          match_name_with_highest_similarity('Młynar') if word.include?('Miynar')
        end
      end

      def match_name_containing(word)
        return unless word.length >= 4

        id = operators.find { |_id, name| name.include?(word) }&.first

        return unless id

        Operator.find(id)
      end

      def find_most_matched_name(word, similarity_threshold)
        matcher = Amatch::Levenshtein.new(word)
        # can optimize here by filter out name with appropriate length
        most_matched_name = operator_names.min_by do |name|
          matcher.match(name)
        end
        similarity = most_matched_name.levenshtein_similar(word)
        Logger.log(word, ['simlarity', word, most_matched_name, similarity])

        most_matched_name if similarity >= similarity_threshold
      end

      def match_name_with_highest_similarity(word, similarity_threshold = NAME_SIMILARITY_THRESHOLD)
        return unless word

        most_matched_name = find_most_matched_name(word, similarity_threshold)

        return unless most_matched_name

        Operator.find(operators.find { |_id, name| name == most_matched_name }.first)
      end

      def box_word
        operator_card_bounding_box.word
      end

      def name_bounding_box
        operator_card_bounding_box.name_bounding_box
      end

      def log_box(operator)
        Logger.log("[#{operator.present?.inspect}] name_bounding_box #{box_word}", name_bounding_box.to_arr)
        Logger.copy_image(nil, Logger.name_box_file_name(box_word)) { image.crop(*name_bounding_box.to_arr) }
      end

      def language
        reader.language
      end

      def compare_image(target_image, source_image, scaled: false)
        target_image = ImageList.new(target_image) unless target_image.is_a?(Image)
        source_image = ImageList.new(source_image) unless source_image.is_a?(Image)
        target_image = target_image.scale(source_image.columns, source_image.rows) unless scaled

        target_image.difference(source_image)
      end

      def redetect_word_from_cropped_box_image
        return '' if name_bounding_box.invalid?

        box_image = Extracting::Processor
                    .make_names_white_on_black(
                      image.crop(*name_bounding_box.to_arr), floodfill_x: name_bounding_box.width * 1.1 / 2, floodfill_y: 0
                    ).color_floodfill(0, 0, 'white').border(10, 10, 'white')
        Logger.copy_image(box_image, "processed_#{Logger.name_box_file_name(box_word)}")
        box_image.write(tmp_file_path)
        reader.read_single_name(tmp_file_path)
      end

      def get_skill_from_image(image, operator, _extracted_data)
        return if operator.skill_game_ids.blank?
        return 1 if operator.skill_game_ids.size == 1

        operator.skill_game_ids.map.with_index do |game_id, index|
          reference_skill_image = SKILL_IMAGE_PATH.join("#{game_id}.png")
          [compare_image(image, reference_skill_image)[0], index + 1]
        end.min_by { |a| a[0] }[1]
      end

      def get_level_from_image(image, operator, _extracted_data)
        return 30 if operator.one_star? || operator.two_stars?

        image.write(tmp_file_path)
        detected = reader.read_digits_only(tmp_file_path)
        return 55 if [0, 5].include?(detected) && operator.three_stars?
        return detected * 10 if (4..7).cover?(detected)
        return 60 if detected == 0

        detected
      end

      def get_elite_from_image(image, operator, extracted_data)
        return 0 unless operator.max_elite.positive?
        return 1 if operator.three_stars? # should elite 1 be most of the times

        possible_elites = operator.possible_elite_with_level(extracted_data[:level])
        return possible_elites.first if possible_elites.size == 1

        greyscaled_image = image.quantize(2, GRAYColorspace)

        if possible_elites.include?(0)
          return 0 if is_elite_0?(greyscaled_image)

          possible_elites.delete(0)
        end
        return possible_elites.first if possible_elites.size == 1

        guess_elite_1_or_2(greyscaled_image)
      end

      def operator_names
        @operator_names ||= operators.map(&:second)
      end

      def is_elite_0?(image)
        compare_image(image, elite_0_image, scaled: true)[0] < compare_image(image, elite_1_image, scaled: true)[0]
      end

      def guess_elite_1_or_2(image)
        color_histogram = image.color_histogram.transform_keys(&:to_color)
        color_histogram['white'] * 1.1 > color_histogram['black'] ? 2 : 1
      end
    end
  end
end
