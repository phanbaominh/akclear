module Clears
  class GetStageIdFromVideoUrl < ApplicationService
    def initialize(video_url)
      @video_url = video_url
    end

    def call
      Success(stages.find { |(_id, code)| video_title.include?(code) }&.first)
    end

    private

    attr_reader :video_url

    def video_data
      @video_data ||= Yt::Video.new(url: video_url)
    end

    def video_title
      video_data.title
    end

    def stages
      Stage.all.non_challenge_mode.pluck(:id, :code)
    end
  end
end
