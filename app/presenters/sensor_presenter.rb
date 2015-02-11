class SensorPresenter < Presenter
  def daily_average
    sensor.daily_average_liters.try(:round)
  end

  private

  alias_method :sensor, :__getobj__
end
