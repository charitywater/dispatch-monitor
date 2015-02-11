ENV['RAILS_ENV'] ||= 'test'
ENV['FLUID_SURVEYS_LIMIT'] = '30'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start if ENV['SEMAPHORE']

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'

Rails.application.load_tasks

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end

RSpec.configure do |config|
  config.order = :random
  config.color = true
  config.tty = true
  config.profile_examples = 4

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.raise_error_on_missing_step_implementation = true
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
end
