class Presenter < SimpleDelegator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  def to_json(*_)
    as_json.to_json
  end

  private

  def l(*args)
    I18n.l(*args)
  end
end
