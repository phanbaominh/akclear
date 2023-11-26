require 'rails_helper'
require 'support/helpers/authentication'
require 'support/helpers/turbo'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
  end

  config.before(:each, :js, :mobile, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [375, 667]
  end

  config.include Helpers::Authentication, type: :system
  config.include Helpers::Turbo, type: :system, js: true
end

Capybara.configure do |config|
  config.enable_aria_label = true
end
