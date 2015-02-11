class SensorList < FilterableList
  def source
    Sensor.includes(:project)
  end

  def filters
    [
      OrderedQuery.new(imei: :asc),
      PaginatedQuery.new(filter_form.page)
    ]
  end

  def presenter
    SensorPresenter
  end
end
