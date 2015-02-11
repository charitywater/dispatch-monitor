require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-sentry'
require 'resque_scheduler'
require 'resque_scheduler/server'

Resque.inline = Rails.env.test?

uri = URI.parse(ENV['REDISTOGO_URL'] || 'localhost:6379')
Resque.redis = Redis.new(
  host: uri.host,
  port: uri.port,
  password: uri.password,
  thread_safe: true,
)

Resque::Failure::Sentry.logger = 'resque'
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Sentry]
Resque::Failure.backend = Resque::Failure::Multiple
