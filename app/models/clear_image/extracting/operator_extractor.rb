class ClearImage
  module Extracting
    class OperatorExtractor
      include Magick
      include TmpFileStorable

      ELITE_0_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite0_reference.png')
      ELITE_1_REFERENCE_IMAGE_PATH = Rails.root.join('app/javascript/images/elite1_reference.png')
      SKILL_IMAGE_PATH = Rails.root.join('app/javascript/images/skills/')
      NAME_SIMILARITY_THRESHOLD = 0.7

      def initialize(operator_card_bounding_box, image, reader)
        @operator_card_bounding_box = operator_card_bounding_box
        @image = image
        @reader = reader
      end

      def extract
        I18n.with_locale(language) do
          word = get_word_from_box(operator_card_bounding_box.name_bounding_box)
          operator = find_operator(word) || find_operator(operator_card_bounding_box.word)

          next unless operator

          result = { operator: }
          %i[skill level elite].each do |component|
            result[component] =
              send(:"get_#{component}_from_image", image.crop(*operator_card_bounding_box.send("#{component}_bounding_box").to_arr),
                   operator)
          end
          result
        end
      end

      private

      attr_reader :operator_card_bounding_box, :image, :reader

      def tmp_file_path
        @tmp_file_path ||= Rails.root.join('tmp/tmp.png').to_s
      end

      def language
        reader.language
      end

      def find_most_matched_name(detected_name)
        most_matched_name = operator_names.min_by do |name|
          Amatch::Levenshtein.new(name).match(detected_name)
        end

        most_matched_name if most_matched_name.levenshtein_similar(detected_name) > NAME_SIMILARITY_THRESHOLD
      end

      def find_operator(detected_name)
        return unless detected_name

        most_matched_name = find_most_matched_name(detected_name)

        return unless most_matched_name

        Operator.find(operators.find { |_id, name| name == most_matched_name }.first)
      end

      def compare_image(target_image, source_image, grayscaled: false)
        target_image = ImageList.new(target_image) unless target_image.is_a?(Image)
        source_image = ImageList.new(source_image) unless source_image.is_a?(Image)
        target_image = target_image.scale(source_image.columns, source_image.rows)
        target_image = target_image.quantize(2, GRAYColorspace) if grayscaled
        source_image = source_image.quantize(2, GRAYColorspace) if grayscaled

        target_image.difference(source_image)
      end

      def get_word_from_box(name_box)
        tmp_file_path = "tmp/tmp_#{name_box.y}_#{name_box.x}.png"
        Extracting::Processor
          .make_names_white_on_black(
            image.crop(*name_box.to_arr), floodfill_x: name_box.width * 1.2 / 2, floodfill_y: 0
          ).write(tmp_file_path)
        reader.read_single_name(tmp_file_path)
      end

      def get_skill_from_image(image, operator)
        return if operator.skill_game_ids.blank?

        operator.skill_game_ids.map.with_index do |game_id, index|
          reference_skill_image = SKILL_IMAGE_PATH.join("#{game_id}.jpg")
          [compare_image(image, reference_skill_image)[0], index + 1]
        end.min_by { |a| a[0] }[1]
      end

      def get_level_from_image(image, _operator)
        image.write(tmp_file_path)
        reader.read_digits_only(tmp_file_path)
      end

      def get_elite_from_image(image, operator)
        detected_elite = if compare_image(image, ELITE_0_REFERENCE_IMAGE_PATH,
                                          grayscaled: true)[0] < compare_image(image, ELITE_1_REFERENCE_IMAGE_PATH,
                                                                               grayscaled: true)[0]
                           0
                         else
                           color_histogram = image.quantize(2,
                                                            GRAYColorspace).color_histogram.transform_keys(&:to_color)
                           color_histogram['white'] * 1.1 > color_histogram['black'] ? 2 : 1
                         end
        [detected_elite, operator.max_elite].min
      end

      def operators
        @operators ||= Operator.i18n.all.pluck(:id, :name).map { |id, name| [id, name.gsub(/\s+/, '')] }
      end

      def operator_names
        @operator_names ||= operators.map(&:second)
      end
    end
  end
end
