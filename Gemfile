source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.1.2'

gem 'rails', '4.1.5'
gem 'rake'

gem 'pg'

gem 'devise'
gem 'pundit'
gem 'paper_trail'

gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'foundation-rails', '~> 5.2.2.0' # https://github.com/zurb/foundation/issues/5251
gem 'foundation-icons-sass-rails'
gem 'compass-rails', '~> 2.0.0'

gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'underscore-rails'
gem 'elementaljs-rails'
gem 'ejs'
gem 'js-routes'
gem 'rails-assets-humanize', '= 0.0.9'

gem 'haml-rails'
gem 'httparty'
gem 'kaminari'
gem 'simple_form'
gem 'nokogiri'
gem 'tzinfo'
gem 'tzinfo-data'

gem 'unicorn'
gem 'newrelic_rpm'
gem 'sentry-raven'
gem 'resque', '~> 1.25', require: 'resque/server'
gem 'resque-scheduler', '~> 2.0'
gem 'resque-sentry'
gem 'rest-client'
gem 'sunspot_rails'
gem 'sunspot_matchers'

group :development do
  gem 'better_errors'
  gem 'brakeman', require: false
  gem 'heroku_san'
  gem 'letter_opener'
  gem 'license_finder'
  gem 'rails-erd'
  gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'codeclimate-test-reporter', require: false
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'simple_bdd', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', require: false
end

group :production, :staging do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'bullet'
  gem 'dotenv-rails'

  gem 'jasmine'
  gem 'jasmine-jquery-rails'

  gem 'jslint_on_rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
