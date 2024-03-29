source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'aasm'
gem 'activerecord-import'
gem 'acts-as-taggable-on'
gem 'after_commit_everywhere', '~> 1.0'
gem 'amatch'
gem 'authentication-zero'
gem 'cancancan'
gem 'dry-initializer-rails'
gem 'dry-monads'
gem 'dry-types'
gem 'faker', require: false
gem 'globalid'
gem 'good_job'
gem 'heroicon'
gem 'meta-tags'
gem 'mobility'
gem 'nokogiri'
gem 'pagy'
gem 'rack-attack'
gem 'rmagick'
gem 'route_translator'
gem 'rtesseract'
gem 'simple_form'
gem 'universalid'
gem 'view_component'
gem 'vite_rails'
gem 'yt'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'awesome_print'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'letter_opener'
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec-rails', '~> 6.1.0'
  gem 'shoulda-matchers'
  gem 'syntax_suggest'
end

group :development do
  gem 'active_record_query_trace'
  gem 'better_html', require: false
  gem 'erb-formatter', require: false
  gem 'erb_lint', require: false
  gem 'htmlbeautifier', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'solargraph', require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
  gem 'memory_profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'test-prof'
  gem 'timecop'
  # gem 'webdrivers' have to remove and upgrade selenium-webdriver to latest version to avoid the request to GET latest_patch_version which is blocked by netskope? (failed due to SSL error)
  gem 'webmock'
end

group :debug, optional: true do
  gem 'stackprof'
  gem 'stackprof-webnav'
end
