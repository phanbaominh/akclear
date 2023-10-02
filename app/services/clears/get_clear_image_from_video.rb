module Clears
  class GetClearImageFromVideo < ApplicationService
    def initialize(video)
      @video = video
    end

    def call
      return Failure(:invalid_video) unless video.valid?
      return Failure(:missing_timestamp) unless video.timestamp

      download_url, status = Open3.capture2('youtube-dl', '-f', '22', '-g', video.to_url)

      return Failure(:failed_to_get_download_url) unless status.success?

      if system('ffmpeg', '-ss', video.timestamp, '-i', download_url, '-t', '1', '-y', '-r', '1',
                clear_image_path)
        Success(clear_image_path)
      else
        Failure(:failed_to_extract_image)
      end
    end

    private

    attr_reader :video

    def clear_image_path
      @clear_image_path ||= Utils.generate_tmp_path(prefix: 'clear', suffix: '.jpg')
    end
  end
end
