class ClearImage
  class Logger
    LOG_DIR = 'tmp/clear_image'
    LOG_FILE = "#{LOG_DIR}/log.txt"

    class << self
      def start(filename)
        return unless should_log?

        File.open(LOG_FILE, 'a') do |f|
          f.puts("=================Start extracting #{filename}===============")
        end
      end

      def log(message, object)
        return unless should_log?

        File.open(LOG_FILE, 'a') do |f|
          f.puts("#{message}")
          f.puts(object.awesome_inspect(plain: true, index: false))
        end
      end

      def copy_image(image, name)
        return unless should_log?

        original_filename = image.filename.split('/').last.split('.').first

        image.write("#{LOG_DIR}/#{original_filename}-#{name}")
      end

      def finish
        return unless should_log?

        File.open(LOG_FILE, 'a') do |f|
          f.puts('=============================')
        end
      end

      private

      def should_log?
        ENV['LOG_CLEAR_IMAGE_EXTRACTION'] == 'true'
      end
    end
  end
end
