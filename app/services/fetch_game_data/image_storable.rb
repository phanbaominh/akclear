# frozen_string_literal: true

require 'open-uri'

module FetchGameData
  module ImageStorable
    def initialize(overwrite: false)
      @overwrite = overwrite
    end

    private

    attr_accessor :overwrite

    def image_storable
      raise NotImplementedError
    end

    def store_images(file_name_to_banner_url)
      count = 0
      log_info("Found #{file_name_to_banner_url.keys.size} #{image_storable} images, storing...")
      folder_path = self.class.images_path
      file_name_to_banner_url.each do |file_name, banner_url|
        path = folder_path.join("#{file_name}.jpg")
        if path.exist? && !overwrite
          log_debug("Skipping image for #{image_storable} #{file_name}, already exist at #{path}")
          next
        end

        log_info("Storing image for  #{image_storable} #{file_name} at #{path}...")
        IO.copy_stream(URI.parse(banner_url).open, path.to_s)
        count += 1
      rescue StandardError => e
        log_info("Failed to store image for  #{image_storable} #{file_name} at #{path} from source #{banner_url}: #{e.message}")
      end
      log_info("Finished storing #{count} new images!")
      Success()
    end
  end
end
