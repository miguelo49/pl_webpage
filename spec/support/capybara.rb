# frozen_string_literal: true

require "capybara/rspec"

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Warden::Test::Helpers, type: :system

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 375, 812 ]
  end

  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
