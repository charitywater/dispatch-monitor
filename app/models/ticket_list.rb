class TicketList < FilterableList
  def source
    filter_form.program.tickets.includes(:project)
  end

  def presenter
    TicketPresenter
  end

  def filters
    [
      Tickets::NonDeletedQuery.new,
      ByStatusQuery.new(filter_form.status),
      Tickets::OrderedQuery.new,
      PaginatedQuery.new(filter_form.page),
    ]
  end
end
