require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before integration: true do
    WebMock.allow_net_connect!
  end
end
