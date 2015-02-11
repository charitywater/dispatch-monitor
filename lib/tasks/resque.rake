require 'resque/tasks'
require 'resque_scheduler/tasks'

namespace :resque do
  desc 'Load Rails environment for Resque'
  task setup: :environment
end
