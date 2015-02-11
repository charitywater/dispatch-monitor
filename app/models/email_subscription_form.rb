class EmailSubscriptionForm < EmailSubscription
  def available_accounts
    @accounts ||= Account.order(email: :asc)
      .where.not(id: EmailSubscription.select(:account_id))
  end
end
