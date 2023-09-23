class ClearImage
  module Extracting
    class Reader
      include TmpFileStorable

      LOCALE_TO_TESSERACT_LANG = {
        en: 'eng',
        jp: 'jpn'
      }.freeze

      def initialize(image)
        @image = image
      end

      def read_digits_only(path)
        RTesseract.new(path, config_file: :digits, psm: '7').to_s.to_i
      end

      def read_sparse_names(path)
        RTesseract.new(path, psm: '11', oem: 1, lang: tess_language_code).to_box
      end

      def read_single_name(path)
        if tess_language_code == 'jpn'
          # run both oem version?
          RTesseract.new(path, psm: '8', lang: tess_language_code, oem: '0')
                    .to_s
                    .strip
                    .tr('一', 'ー') # ichi vs long dahsh
                    .tr('夕', 'タ') # yuu vs ta
                    .gsub(/^ー*/, '')
                    .gsub(/^[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}]*/, '')
        else
          RTesseract.new(path, psm: '13', lang: tess_language_code).to_s
        end
      end

      def language
        return @language if @language

        Extracting::Processor.make_names_white_on_black(image).write(tmp_file_path)
        all_characters_regex = /[^\p{Latin}\p{Hiragana}\p{Katakana}\p{Han}]+/u
        @language ||= LOCALE_TO_TESSERACT_LANG.max_by do |_locale, tess_lang_code|
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
