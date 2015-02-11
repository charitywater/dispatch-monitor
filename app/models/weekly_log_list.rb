class WeeklyLogList < FilterableList
  def source
    WeeklyLog.all
  end

  def filters
    [
      OrderedQuery.new(received_at: :desc),
      PaginatedQuery.new(filter_form.page)
    ]
  end

  def presenter
    WeeklyLogPresenter
  end
end
