FactoryBot.define do
  factory :extract_clear_data_from_video_job do
    data { '' }
    # stage need to be before video_url so that job does not try to set a new stage based on video_url
    stage
    sequence(:video_url) { |i| "https://www.youtube.com/watch?v=aAfeBGKoZeI#{i}" }

    trait :completed do
      status { :completed }
    end
  end
end
