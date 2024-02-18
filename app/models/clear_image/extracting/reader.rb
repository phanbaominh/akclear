# frozen_string_literal: true

class ClearImage
  module Extracting
    class Reader
      LOCALE_TO_TESSERACT_LANG = {
        en: 'eng',
        jp: 'jpn',
        'zh-CN': 'chi_sim',
        ko: 'kor'
      }.freeze
      NON_CHARACTERS_REGEX = /[^0-9\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}\p{Hangul}ー-]+/u
      class << self
        include TmpFileStorable

        LOCALE_TO_TESSERACT_LANG.each_key do |locale|
          define_method("#{locale.to_s.underscore}?") do
            language == locale
          end
        end

        def read_digits_only(path)
          RTesseract.new(path, config_file: :digits, psm: '7').to_s.to_i
        end

        def read_lined_names(path)
          [7, 11].map do |psm|
            [RTesseract.new(path, psm:, oem: 1, lang: tess_language_code).to_box, psm]
          end.max_by { |result| result.first.pluck(:word).join.gsub(NON_CHARACTERS_REGEX, '').bytesize }
        end

        def read_lined_names_text(path, psm:)
          text = RTesseract.new(path, psm:, oem: 1, lang: tess_language_code).to_s
          words = text.split(/\s+/)
          words.map do |word|
            word.gsub(NON_CHARACTERS_REGEX, '')
          end.compact_blank
        end

        def read_sparse_names(path)
          [RTesseract.new(path, psm: '11', oem: 1, lang: tess_language_code).to_box, 11]
        end

        def read_single_name(path)
          if jp?
            # run both oem version?
            process_name(RTesseract.new(path, psm: '3', lang: tess_language_code, oem: 1).to_s)
          elsif zh_cn?
            process_name(RTesseract.new(path, psm: '7', lang: tess_language_code).to_s)
          else
            process_name(RTesseract.new(path, psm: '11', lang: tess_language_code).to_s)
          end
        end

        def process_name(name)
          if jp?
            name.strip
                .tr('一', 'ー') # ichi vs long dahsh
                .tr('夕', 'タ') # yuu vs ta
                .tr('ヵ', 'カ')
                # .gsub(/^ー*/, '')
                .gsub(/\s/, '')
                .gsub(/^[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}ー]*/, '')
          elsif zh_cn?
            name.gsub(/\s/, '').gsub(/^[^\p{Latin}\p{Han}]*/, '')
          elsif ko?
            name.gsub(/\s/, '').gsub(/^[^\p{Latin}\p{Hangul}]*/, '')
          else
            name.gsub(/\W/, '')
          end
        end

        def language
          Thread.current[:clear_image_language]
        end

        def language=(language)
          Thread.current[:clear_image_language] = language
        end

        def extract_language(processed_image: nil, possible_languages: [])
          return if language

          Extracting::Processor.make_names_white_on_black(image).write(tmp_file_path) unless processed_image
          all_characters_regex = /[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}\p{Hangul}]+/u
          Thread.current[:clear_image_language] = LOCALE_TO_TESSERACT_LANG.max_by do |locale, tess_lang_code|
            next 0 if possible_languages.map(&:to_s).exclude?(locale.to_s)

            RTesseract.new(tmp_file_path.to_s, psm: '11', lang: tess_lang_code).to_box
                      .select { |box| box[:confidence] > 80 }
                      .pluck(:word)
                      .join
                      .gsub(all_characters_regex, '').size
          end.first
        end

        private

        attr_reader :image

        def tess_language_code
          LOCALE_TO_TESSERACT_LANG[language]
        end
      end
    end
  end
end
