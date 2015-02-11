class VehicleList < FilterableList
  def source
    Vehicle.includes(:program => [:partner, :country])
  end

  def presenter
    VehiclePresenter
  end

  def filters
    [
      OrderedQuery.new(vehicle_type: :asc),
      PaginatedQuery.new(filter_form.page)
    ]
  end
end
