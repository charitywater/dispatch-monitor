class ProjectList < FilterableList
  def source
    filter_form.program.projects.includes(:country)
  end

  def presenter
    ProjectPresenter
  end

  def filters
    if filter_form.sort_column.nil? || filter_form.sort_direction.nil?
      ordered_query = "deployment_code asc"
    else
      ordered_query = filter_form.sort_column + " " + filter_form.sort_direction
    end

    [
      ByStatusQuery.new(filter_form.status),
      OrderedQuery.new(ordered_query),
      PaginatedQuery.new(filter_form.page),
    ]
  end
end
