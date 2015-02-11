module Hover
  def hover(locator)
    find_link(locator).hover if js?
  end

  def js?
    %i(poltergeist selenium).include?(Capybara.current_driver)
  end
end

RSpec.configure do |config|
  config.include Hover, type: :feature, js: true
end
