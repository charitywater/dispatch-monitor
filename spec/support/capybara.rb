require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/email/rspec'

# debugging_timeout = 60
Capybara.register_driver :poltergeist do |app|
  options = {
    phantomjs_options: ['--local-to-remote-url-access=true'],
    # timeout: debugging_timeout,
  }
  Capybara::Poltergeist::Driver.new(app, options)
end
# Capybara.default_wait_time = debugging_timeout

Capybara.javascript_driver = ENV['SELENIUM'] ? :selenium : :poltergeist
