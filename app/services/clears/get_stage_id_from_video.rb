module Clears
  class GetStageIdFromVideo < ApplicationService
    def initialize(video)
      @video = video
    end

    def call
      return Failure(:invalid_video) unless video.valid?

      Success(stages.find { |(_id, code)| video.title.include?(code) }&.first)
    end

    private

    attr_reader :video

    def stages
      Stage.all.non_challenge_mode.pluck(:id, :code)
    end
  end
end
