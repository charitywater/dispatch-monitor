class EmailSubscriptionList < FilterableList
  def source
    EmailSubscription.includes(:account).joins(:account)
  end

  def filters
    [
      OrderedQuery.new('subscription_type ASC, accounts.email ASC'),
      PaginatedQuery.new(filter_form.page)
    ]
  end

  def presenter
    EmailSubscriptionPresenter
  end
end
