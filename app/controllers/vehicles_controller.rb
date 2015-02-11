class VehiclesController < ApplicationController
  def index
    @vehicles = VehicleList.new(FilterForm.new(filter_params))
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      redirect_to vehicles_path,
        success: t(
          '.success',
          esn: @vehicle.esn,
          vehicle_type: @vehicle.vehicle_type
      )
    else
      flash.now[:alert] = t('.alert')
      render :new
    end
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
  end

  def update
    vehicle = Vehicle.find(params[:id])

    if vehicle.update(vehicle_params)
      redirect_to vehicles_path, success: t('.success', esn: vehicle.esn)
    else
      flash.now[:alert] = t('.alert')
      render :edit
    end
  end

  private

  def vehicle_params
    params.require(:vehicle)
      .permit(:esn, :vehicle_type, :program_id)
      .tap do |s|
        s[:esn].strip!
        s[:vehicle_type].strip!
        s[:program_id].to_i
      end
  end
end
