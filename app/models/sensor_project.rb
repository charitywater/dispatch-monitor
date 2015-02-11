class SensorProject
  include ActiveModel::Model

  attr_accessor :deployment_code, :device_id, :imei

  validate :project_exists, :device_id_is_unique, :imei_is_unique, :project_has_no_sensor_yet

  delegate :community_name, to: :project

  def save
    # device_id will always be the IMEI with the first and last chars removed
    device_id = imei.clone
    device_id.slice!(0)
    device_id.chop!
    if valid?
      project.create_sensor(device_id: device_id, imei: imei)
    end
  end

  private

  def project
    @project ||= Project.find_by(deployment_code: deployment_code)
  end

  def project_exists
    unless project
      errors.add(:deployment_code, 'does not exist')
    end
  end

  def device_id_is_unique
    if Sensor.find_by(device_id: device_id)
      errors.add(:device_id, 'device id already in use')
    end
  end

  def imei_is_unique
    if Sensor.find_by(imei: imei)
      errors.add(:imei, 'imei already in use')
    end
  end

  def project_has_no_sensor_yet
    if project && project.sensor.present?
      errors.add(:deployment_code, 'already has a sensor')
    end
  end
end
