module Clears
  class BuildClearFromVideo < ApplicationService
    def initialize(video, submitter)
      @video = video
      @submitter = submitter
    end

    def call
      return Failure(:invalid_video) unless video.valid?

      image_path = yield Clears::GetClearImageFromVideo.call(video)
      used_operators_attributes = yield BuildUsedOperatorsAttrsFromImage.call(image_path)
      stage_id = yield Clears::GetStageIdFromVideo.call(video)
      clear_attrs = {
        stage_id:,
        used_operators_attributes:,
        link: video.to_url,
        submitter:
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
