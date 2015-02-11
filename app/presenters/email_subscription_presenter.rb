class EmailSubscriptionPresenter < Presenter
  def subscription_type
    email_subscription.subscription_type.titleize
  end

  private

  alias_method :email_subscription, :__getobj__
end
