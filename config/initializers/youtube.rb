Yt.configure do |config|
  config.api_key = Rails.application.credentials.youtube_api_key
  config.log_level = 'devel' unless Rails.env.production?
end
