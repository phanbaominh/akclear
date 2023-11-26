require 'rails_helper'
require 'support/helpers/authentication'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome
  end
  config.include Helpers::Authentication, type: :system
end

Capybara.configure do |config|
  config.enable_aria_label = true
end
