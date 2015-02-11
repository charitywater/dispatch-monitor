module Selenium
  def selenium?
    !!ENV['SELENIUM']
  end
end

RSpec.configure do |config|
  config.include Selenium, type: :feature
end
