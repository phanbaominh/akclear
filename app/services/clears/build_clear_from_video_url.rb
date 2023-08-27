module Clears
  class BuildClearFromVideoUrl < ApplicationService
    def initialize(video_url, submitter)
      @video_url = video_url
      @submitter = submitter
    end

    def call
      image_path = yield Clears::GetClearImageFromVideoUrl.call(video_url)
      used_operators_attributes = yield BuildUsedOperatorsAttrsFromImage.call(image_path)
      stage_id = yield Clears::GetStageIdFromVideoUrl.call(video_url)
      clear_attrs = {
        stage_id:,
        used_operators_attributes:,
        link: video_url,
        submitter:
      }
      clear = Clear.new(clear_attrs)

      Success(clear)
    end

    private

    attr_reader :video_url, :submitter
  end
end
