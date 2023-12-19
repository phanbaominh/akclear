module Clears
  class BuildClearFromVideo < ApplicationService
    def initialize(video)
      @video = video
    end

    def call
      return Failure(:invalid_video) unless video.valid?

      image_path = yield Clears::GetClearImageFromVideo.call(video)
      used_operators_attributes = yield BuildUsedOperatorsAttrsFromImage.call(image_path)
      clear_attrs = {
        used_operators_attributes:,
        link: video.to_url(normalized: true)
      }
      clear = Clear.new(clear_attrs)

      Success(clear)
    end

    private

    attr_reader :video, :submitter
  end
  # TODO: compile channel list and fetch all video urls
  # TODO: create model BuildClearFromVideoJob and controller
end
