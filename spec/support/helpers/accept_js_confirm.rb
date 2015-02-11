module AcceptJsConfirm
  def accept_js_alert
    page.driver.browser.switch_to.alert.accept if selenium?
  end
end

RSpec.configure do |config|
  config.include AcceptJsConfirm, type: :feature
end
