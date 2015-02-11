class VehiclePresenter < Presenter
  def vehicle_type
    vehicle.vehicle_type.nil? ? "N/A" : vehicle.vehicle_type.titleize
  end

  def program
    vehicle.program.nil? ? "N/A" : "#{vehicle.program.partner.name} - #{vehicle.program.country.name}"
  end

  private

  alias_method :vehicle, :__getobj__
end
