require 'vcr'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = ENV['SEMAPHORE'] ? '.semaphore-cache/cassettes' : 'tmp/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :new_episodes,
    re_record_interval: 7.days
  }
end

VCR.turn_off!

RSpec.configure do |config|
  config.before :all, vcr: true do
    VCR.turn_on!
  end

  config.after :all, vcr: true do
    VCR.turn_off!
  end
end
