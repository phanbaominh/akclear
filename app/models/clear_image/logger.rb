# frozen_string_literal: true

class ClearImage
  class Logger
    LOG_DIR = 'tmp/clear_image'
    LOG_FILE = 'log.txt'
    LOG_DIR_THREAD_KEY = :clear_image_extracting_log_dir_path
    CONFIG_FILE = 'config.json'
    IMAGE_NAMES = [
      NAME_BLACK_ON_WHITE = 'name_black_on_white.png',
      WHITE_OVER_NON_NAMES_1 = 'white_over_non_names_1.png',
      WHITE_OVER_NON_NAMES_2 = 'white_over_non_names_2.png',
      NAME_BOX = 'name_box'
    ].freeze

    class << self
      def name_box_file_name(word)
        "#{NAME_BOX}_#{word}.png"
      end

      def start(filename)
        return unless should_log?

        File.open(log_file_path, 'w') do |f|
          f.puts("=================Start extracting #{filename}===============")
        end
      end

      def log(message, object)
        return unless should_log?

        File.open(log_file_path, 'a') do |f|
          f.puts message
          f.puts(object.awesome_inspect(plain: true, index: false))
        end
      end

      def copy_image(image, name)
        return unless should_log?

        prefix, ext = name.split('.')
        new_name = [prefix, Time.now.to_i, ext].join('.')

        (block_given? ? yield : image).write("#{dir_path}/#{new_name}")
      end

      def finish
        return unless should_log?

        File.write("#{dir_path}/#{CONFIG_FILE}", Configuration.used_instance.attributes.to_json)
      end

      def dir_path_for_current_thread=(dir_path)
        Thread.current[LOG_DIR_THREAD_KEY] = dir_path
      end

      private

      def log_file_path
        "#{dir_path}/#{LOG_FILE}"
      end

      def dir_path
        Thread.current[LOG_DIR_THREAD_KEY] || LOG_DIR
      end

      def should_log?
        ENV['CLEAR_IMAGE_LOG'] == 'true'
      end
    end
  end
end
