class AccountList < FilterableList
  def source
    Account.includes(program: [:partner, :country])
  end

  def filters
    [
      OrderedQuery.new(email: :asc),
      PaginatedQuery.new(filter_form.page)
    ]
  end

  def presenter
    AccountPresenter
  end
end
