class SensorsController < AdminController
  def index
    @sensors = SensorList.new(FilterForm.new(filter_params))
  end

  def new
    @sensor = SensorProject.new
  end

  def create
    @sensor = SensorProject.new(sensor_project_params)

    if @sensor.save
      redirect_to sensors_path,
        success: t(
          '.success',
          device_id: @sensor.device_id,
          imei: @sensor.imei,
          deployment_code: @sensor.deployment_code,
          community_name: @sensor.community_name,
      )
    else
      flash.now[:alert] = t('.alert')
      render :new
    end
  end

  def destroy
    sensor = Sensor.find(params[:id])

    sensor.destroy

    redirect_to sensors_path,
        success: t(
          '.success',
          device_id: sensor.device_id,
          imei: sensor.imei,
          deployment_code: sensor.deployment_code,
          community_name: sensor.community_name,
      )
  end

  private

  def sensor_project_params
    params.require(:sensor_project)
      .permit(:device_id, :deployment_code, :imei)
      .tap do |s|
        s[:imei].strip!
        s[:deployment_code].strip!
      end
  end
end
