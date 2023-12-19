require 'rails_helper'
require 'support/helpers/authentication'
require 'support/helpers/turbo'
require 'support/helpers/js'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  browser = ENV['DEBUG_SYSTEM_SPEC'] ? :chrome : :headless_chrome

  config.before(:each, :js, type: :system) do
    driven_by :selenium, using: browser, screen_size: [1400, 1400]
  end

  config.before(:each, :js, :mobile, type: :system) do
    # name option is important, otherwise Capybara won't switch between two same driver types
    # due to how rails system test register (actionpack) all drivers with driver type as name unless specified
    driven_by :selenium, using: browser, screen_size: [375, 667], options: { name: :selenium_mobile }
  end

  config.include Helpers::Authentication, type: :system
  config.include Helpers::Turbo, type: :system, js: true
  config.include Helpers::Js, type: :system, js: true
end

Capybara.configure do |config|
  config.enable_aria_label = true
end
