require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module RemoteMonitoring
  class Application < Rails::Application
    config.time_zone = 'UTC'
    config.autoload_paths += %w(lib)
    config.assets.initialize_on_precompile = false
  end
end
