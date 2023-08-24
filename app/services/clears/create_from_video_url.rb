module Clears
  class CreateFromVideoUrl < ApplicationService
    def initialize(video_url)
      @video_url = video_url
    end

    def call
      I18n.with_locale(:jp) do
        image_path = yield Clears::GetClearImageFromVideoUrl.call(video_url)
        clear_attrs = yield BuildAttrsFromImage.call(image_path)

        if (clear = Clear.build(clear_attrs))
          Success(clear)
        else
          Failure(:failed_to_create_clear, clear.errors)
        end
      end
    end

    private

    attr_reader :video_url
  end
end
