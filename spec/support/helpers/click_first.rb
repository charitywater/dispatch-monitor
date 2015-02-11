module ClickFirst
  def click_first_link(locator)
    first(:link, locator).click
  end

  def click_first_button(locator)
    first(:button, locator).click
  end
end

RSpec.configure do |config|
  config.include ClickFirst, type: :feature
end
