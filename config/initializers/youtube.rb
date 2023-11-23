Yt.configure do |config|
  config.api_key = ENV.fetch('YOUTUBE_API_KEY', nil)
  config.log_level = 'devel' unless Rails.env.production?
end
