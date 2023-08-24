module Clears
  class GetClearImageFromVideoUrl < ApplicationService
    YOUTUBE_REGEX = %r{(?:https?://)?(?:www\.)?(?:youtube\.com|youtu\.be)/(?:watch\?v=)?(.+)}

    def initialize(video_url)
      @video_url = video_url
    end

    def call
      return Failure(:invalid_url) unless valid?

      download_url, status = Open3.capture2('youtube-dl', '-f', '22', '-g', video_url)

      return Failure(:failed_to_get_download_url) unless status.success?

      if system('ffmpeg', '-ss', timestamp, '-i', download_url, '-t', '1', '-y', '-r', '1',
                clear_image_path)
        Success(clear_image_path)
      else
        Failure(:failed_to_extract_image)
      end
    end

    private

    attr_reader :video_url

    def clear_image_path
      @clear_image_path ||= 'testser.png' # Utils.generate_tmp_path(prefix: 'clear', suffix: '.jpg')
    end

    def timestamp
      CGI.parse(URI.parse(video_url).query)['t'].first
    end

    def valid?
      YOUTUBE_REGEX.match?(video_url)
    end
  end
end
