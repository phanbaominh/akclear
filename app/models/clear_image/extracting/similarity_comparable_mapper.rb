# frozen_string_literal: true

class ClearImage
  module Extracting
    class SimilarityComparableMapper
      KATAKANA_GROUPING = %w[
        ァア ィイ ゥウヴ ェエ ォオ カガ キギ クグ ケゲ コゴ サザ シジ スズ セゼ ソゾ タダ チヂ ッツヅ
        テデ トド ハバパ ヒビピ フブプ ヘベペ ホボポ
        ャヤ ュユ ョヨ ヮワヷ
      ].freeze
      KATAKANA_MAPPING = KATAKANA_GROUPING.each_with_index.with_object({}) do |(group, first_byte), mapping|
        group.chars.each_with_index do |char, second_byte|
          mapping[char] = [first_byte, second_byte].pack('C*').force_encoding(Encoding::UTF_8)
        end
      end.freeze

      def initialize(operators)
        @mapping = build_mapping(operators)
      end

      def build_mapping(operators)
        return unless Reader.jp?

        start_byte = 33

        mapping = operators.map do |op|
                    op.name(locale: Reader.language)
                  end.join.chars.uniq.sort.each_with_index.with_object({}) do |(char, i), result|
          result[char] = (start_byte + i).chr(Encoding::UTF_8)
        end
        @unknown_char = (mapping.keys.size + start_byte).chr(Encoding::UTF_8)
        mapping.merge!(KATAKANA_MAPPING)
        mapping
      end

      def map(word)
        return word unless @mapping

        word.chars.map { |c| @mapping[c] || @unknown_char }.join
      end
    end
  end
end
